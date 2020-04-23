# Distributed under the terms of the GNU General Public License v2

EAPI="6"
WANT_AUTOCONF="2.1"

inherit autotools check-reqs toolchain-funcs pax-utils mozcoreconf-v5

DESCRIPTION="Stand-alone JavaScript C++ library"
HOMEPAGE="https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey"
SRC_URI="https://archive.mozilla.org/pub/firefox/releases/${PV}esr/source/firefox-${PV}esr.source.tar.xz"

LICENSE="NPL-1.1"
SLOT="68/7.0"
KEYWORDS="~*"

IUSE="debug +jit minimal +system-icu test"

RESTRICT="!test? ( test ) ia64? ( test )"

S="${WORKDIR}/firefox-${PV}"
BUILDDIR="${S}/jsobj"

RDEPEND=">=dev-libs/nspr-4.13.1
	dev-libs/libffi
	sys-libs/readline:0=
	>=sys-libs/zlib-1.2.3:=
	system-icu? ( >=dev-libs/icu-59.1:= )"
DEPEND="${RDEPEND}"

pkg_pretend() {
	CHECKREQS_DISK_BUILD="2G"

	check-reqs_pkg_setup
}

pkg_setup() {
	[[ ${MERGE_TYPE} == "binary" ]] || \
		moz_pkgsetup
	export SHELL="${EPREFIX}/bin/bash"
}

src_prepare() {
	eapply_user

	if [[ ${CHOST} == *-freebsd* ]]; then
		# Don't try to be smart, this does not work in cross-compile anyway
		ln -sfn "${BUILDDIR}/config/Linux_All.mk" "${S}/config/$(uname -s)$(uname -r).mk" || die
	fi

	cd "${S}"/js/src || die
	eautoconf old-configure.in
	eautoconf

	# remove options that are not correct from js-config
	sed '/lib-filenames/d' -i "${S}"/js/src/build/js-config.in || die "failed to remove invalid option from js-config"

	# there is a default config.cache that messes everything up
	rm -f "${S}"/js/src/config.cache || die

	mkdir -p "${BUILDDIR}" || die
}

src_configure() {
	cd "${BUILDDIR}" || die

	${S}/js/src/configure \
		--prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--disable-jemalloc \
		--enable-readline \
		--with-system-nspr \
		--with-system-zlib \
		--disable-optimize \
		--with-intl-api \
		$(use_with system-icu) \
		$(use_enable debug) \
		$(use_enable debug debug-symbols) \
		$(use_enable jit ion) \
		$(use_enable test tests) \
		XARGS="/usr/bin/xargs" \
		CONFIG_SHELL="${EPREFIX}/bin/bash" \
		CC="${CC}" CXX="${CXX}" LD="${LD}" AR="${AR}"
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
	cd "${BUILDDIR}" || die
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
	cd "${BUILDDIR}/js/src/jsapi-tests" || die
	./jsapi-tests || die
}

src_install() {
	cd "${BUILDDIR}" || die
	emake DESTDIR="${D}" install

	if ! use minimal; then
		if use jit; then
			pax-mark m "${ED}"usr/bin/js${SLOT}
		fi
	else
		rm -f "${ED}"usr/bin/js${SLOT}
	fi

	# We can't actually disable building of static libraries
	# They're used by the tests and in a few other places
	find "${D}" -iname '*.a' -o -iname '*.ajs' -delete || die
}