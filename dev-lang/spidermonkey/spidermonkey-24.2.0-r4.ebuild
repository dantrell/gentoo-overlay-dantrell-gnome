# Distributed under the terms of the GNU General Public License v2

EAPI="6"
WANT_AUTOCONF="2.1"
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="threads(+)"

inherit autotools toolchain-funcs multilib python-any-r1 versionator pax-utils

MY_PN="mozjs"
MY_P="${MY_PN}-${PV/_/.}"

DESCRIPTION="Mozilla's JavaScript engine written in C and C++"
HOMEPAGE="https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey"
SRC_URI="https://archive.mozilla.org/pub/js/${MY_P}.tar.bz2
	https://dev.gentoo.org/~axs/distfiles/${PN}-slot24-patches-01.tar.xz"

LICENSE="NPL-1.1"
SLOT="24"
KEYWORDS="*"

IUSE="debug icu jit minimal static-libs +system-icu test"

RESTRICT="!test? ( test )"

RDEPEND=">=dev-libs/nspr-4.9.4
	dev-libs/libffi:=
	sys-libs/readline:0=
	>=sys-libs/zlib-1.1.4
	system-icu? ( >=dev-libs/icu-1.51:= )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	app-arch/zip
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P%.rc*}"
MOZJS_BUILDDIR="${S}/js/src"

PATCHES=(
	"${WORKDIR}"/sm24/${PN}-${SLOT%/*}-system-icu.patch
	"${WORKDIR}"/sm24/${PN}-24.2.0-fix-file-permissions.patch
	"${WORKDIR}"/sm24/${PN}-${SLOT%/*}-upward-growing-stack.patch
	"${FILESDIR}"/${PN}-perl-defined-array-check.patch
	"${WORKDIR}"/sm24/${PN}-17-fix_pointer_dereference.patch
	"${FILESDIR}"/${PN}-24.2.0-update-common-python-code.patch

	# From Boost:
	# 	https://github.com/boostorg/coroutine/issues/23
	# 	https://gcc.gnu.org/gcc-11/porting_to.html
	"${FILESDIR}"/${PN}-24.2.0-gcc-11.patch
)

pkg_setup() {
	if [[ ${MERGE_TYPE} != "binary" ]]; then
		python-any-r1_pkg_setup
		export LC_ALL="C"
	fi
}

src_prepare() {
	default

	if [[ ${CHOST} == *-freebsd* ]]; then
		# Don't try to be smart, this does not work in cross-compile anyway
		ln -sfn "${MOZJS_BUILDDIR}/config/Linux_All.mk" "${S}/config/$(uname -s)$(uname -r).mk" || die
	fi

	cd "${MOZJS_BUILDDIR}" || die
	eautoconf
}

src_configure() {
	export SHELL=/bin/sh
	cd "${MOZJS_BUILDDIR}" || die

	local myopts=""
	if use icu; then # make sure system-icu flag only affects icu-enabled build
		myopts+="$(use_with system-icu)"
	else
		myopts+="--without-system-icu"
	fi

	CC="$(tc-getCC)" CXX="$(tc-getCXX)" \
	AR="$(tc-getAR)" RANLIB="$(tc-getRANLIB)" \
	LD="$(tc-getLD)" \
	econf \
		${myopts} \
		--enable-jemalloc \
		--enable-readline \
		--enable-threadsafe \
		--with-system-nspr \
		--enable-system-ffi \
		--disable-optimize \
		$(use_enable icu intl-api) \
		$(use_enable debug) \
		$(use_enable jit yarr-jit) \
		$(use_enable jit ion) \
		$(use_enable static-libs static) \
		$(use_enable test tests)
}

cross_make() {
	emake \
		CFLAGS="${BUILD_CFLAGS}" \
		CXXFLAGS="${BUILD_CXXFLAGS}" \
		AR="${BUILD_AR}" \
		CC="${BUILD_CC}" \
		CXX="${BUILD_CXX}" \
		RANLIB="${BUILD_RANLIB}" \
		"$@"
}

src_compile() {
	cd "${MOZJS_BUILDDIR}" || die
	if tc-is-cross-compiler; then
		tc-export_build_env BUILD_{AR,CC,CXX,RANLIB}
		cross_make \
			MOZ_OPTIMIZE_FLAGS="" MOZ_DEBUG_FLAGS="" \
			HOST_OPTIMIZE_FLAGS="" MODULE_OPTIMIZE_FLAGS="" \
			MOZ_PGO_OPTIMIZE_FLAGS="" \
			host_jsoplengen host_jskwgen
		cross_make \
			MOZ_OPTIMIZE_FLAGS="" MOZ_DEBUG_FLAGS="" HOST_OPTIMIZE_FLAGS="" \
			-C config nsinstall
		mv {,native-}host_jskwgen || die
		mv {,native-}host_jsoplengen || die
		mv config/{,native-}nsinstall || die
		sed -i \
			-e 's@./host_jskwgen@./native-host_jskwgen@' \
			-e 's@./host_jsoplengen@./native-host_jsoplengen@' \
			Makefile || die
		sed -i -e 's@/nsinstall@/native-nsinstall@' config/config.mk || die
		rm -f config/host_nsinstall.o \
			config/host_pathsub.o \
			host_jskwgen.o \
			host_jsoplengen.o || die
	fi
	emake \
		MOZ_OPTIMIZE_FLAGS="" MOZ_DEBUG_FLAGS="" \
		HOST_OPTIMIZE_FLAGS="" MODULE_OPTIMIZE_FLAGS="" \
		MOZ_PGO_OPTIMIZE_FLAGS=""
}

src_test() {
	cd "${MOZJS_BUILDDIR}/jsapi-tests" || die
	emake check
}

src_install() {
	cd "${MOZJS_BUILDDIR}" || die
	default

	if ! use minimal; then
		if use jit; then
			pax-mark m "${ED}/usr/bin/js${SLOT%/*}" || die
		fi
	else
		rm -f "${ED}/usr/bin/js${SLOT%/*}" || die
	fi

	if ! use static-libs; then
		# We can't actually disable building of static libraries
		# They're used by the tests and in a few other places
		find "${D}" -iname '*.a' -delete || die
	fi
}
