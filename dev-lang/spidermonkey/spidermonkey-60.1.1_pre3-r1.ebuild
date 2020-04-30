# Distributed under the terms of the GNU General Public License v2

EAPI="6"
WANT_AUTOCONF="2.1"

inherit autotools toolchain-funcs pax-utils mozcoreconf-v5

MY_PN="mozjs"
MY_P="${MY_PN}-${PV/_rc/.rc}"
MY_P="${MY_P/_pre/pre}"

DESCRIPTION="Mozilla's JavaScript engine written in C and C++"
HOMEPAGE="https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey"
SRC_URI="http://ftp.mozilla.org/pub/spidermonkey/prereleases/60/pre3/mozjs-60.1.1pre3.tar.bz2 -> ${MY_P}.tar.bz2
	https://dev.gentoo.org/~axs/distfiles/${PN}-60.0-patches-02.tar.xz"

LICENSE="NPL-1.1"
SLOT="60/1.1"
KEYWORDS="*"

IUSE="debug minimal +system-icu test"

RESTRICT="!test? ( test ) ia64? ( test )"

RDEPEND=">=dev-libs/nspr-4.13.1
	dev-libs/libffi
	sys-libs/readline:0=
	>=sys-libs/zlib-1.2.3
	system-icu? ( >=dev-libs/icu-58.1:= )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P%.rc*}"
MOZJS_BUILDDIR="${S}/jsobj"

pkg_setup() {
	[[ ${MERGE_TYPE} == "binary" ]] || \
		moz_pkgsetup
}

src_prepare() {
	eapply "${WORKDIR}"/${PN}

	eapply_user

	if [[ ${CHOST} == *-freebsd* ]]; then
		# Don't try to be smart, this does not work in cross-compile anyway
		ln -sfn "${MOZJS_BUILDDIR}/config/Linux_All.mk" "${S}/config/$(uname -s)$(uname -r).mk" || die
	fi

	cd "${S}"/js/src || die
	eautoconf old-configure.in
	eautoconf

	# there is a default config.cache that messes everything up
	rm -f "${S}"/js/src/config.cache || die

	mkdir -p "${MOZJS_BUILDDIR}" || die
}

src_configure() {
	cd "${MOZJS_BUILDDIR}" || die

	ECONF_SOURCE="${S}/js/src" \
	econf \
		--disable-jemalloc \
		--enable-readline \
		--with-system-nspr \
		--disable-optimize \
		--with-intl-api \
		$(use_with system-icu) \
		$(use_enable debug) \
		$(use_enable test tests) \
		XARGS="/usr/bin/xargs" \
		SHELL="${SHELL:-${EPREFIX}/bin/bash}" \
		CC="${CC}" CXX="${CXX}" LD="${LD}" AR="${AR}" RANLIB="${RANLIB}"
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

	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
	emake \
		MOZ_OPTIMIZE_FLAGS="" MOZ_DEBUG_FLAGS="" \
		HOST_OPTIMIZE_FLAGS="" MODULE_OPTIMIZE_FLAGS="" \
		MOZ_PGO_OPTIMIZE_FLAGS=""
}

src_test() {
	cd "${MOZJS_BUILDDIR}/js/src/jsapi-tests" || die
	./jsapi-tests || die
}

src_install() {
	cd "${MOZJS_BUILDDIR}" || die
	emake DESTDIR="${D}" install

	if ! use minimal; then
		pax-mark m "${ED}"usr/bin/js${SLOT}
	else
		rm -f "${ED}"usr/bin/js${SLOT}
	fi

	# We can't actually disable building of static libraries
	# They're used by the tests and in a few other places
	find "${D}" -iname '*.a' -o -iname '*.ajs' -delete || die
}
