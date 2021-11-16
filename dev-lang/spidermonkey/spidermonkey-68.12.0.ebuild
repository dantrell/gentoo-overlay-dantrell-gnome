# Distributed under the terms of the GNU General Public License v2

EAPI="7"
WANT_AUTOCONF="2.1"

inherit autotools check-reqs pax-utils toolchain-funcs

MY_PN="mozjs"
MY_MAJOR=$(ver_cut 1)

DESCRIPTION="Mozilla's JavaScript engine written in C and C++"
HOMEPAGE="https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey"
SRC_URI="https://archive.mozilla.org/pub/firefox/releases/${PV}esr/source/firefox-${PV}esr.source.tar.xz"

# Patch version
FIREFOX_PATCHSET="firefox-68.0-patches-15"
SPIDERMONKEY_PATCHSET="${PN}-68.6.0-patches-04"

PATCH_URIS=(
	https://dev.gentoo.org/~{anarchy,whissi,polynomial-c,axs}/mozilla/patchsets/${FIREFOX_PATCHSET}.tar.xz
	https://dev.gentoo.org/~{whissi,polynomial-c,axs}/mozilla/patchsets/${SPIDERMONKEY_PATCHSET}.tar.xz
)

SRC_URI+="
	${PATCH_URIS[@]}"

LICENSE="MPL-2.0"
SLOT="68/12.0"
KEYWORDS="*"

IUSE="clang debug +jit minimal +system-icu test"

RESTRICT="!test? ( test ) ia64? ( test )"

BDEPEND="dev-lang/python:2.7"
DEPEND="
	system-icu? ( >=dev-libs/icu-63.1:= )
	>=dev-libs/nspr-4.21
	dev-libs/libffi:=
	sys-libs/readline:0=
	>=sys-libs/zlib-1.2.3:=
	|| (
		(
			sys-devel/clang:13
			!clang? ( sys-devel/llvm:13 )
			clang? (
				=sys-devel/lld-13*
				sys-devel/llvm:13[gold]
			)
		)
		(
			sys-devel/clang:12
			!clang? ( sys-devel/llvm:12 )
			clang? (
				=sys-devel/lld-12*
				sys-devel/llvm:12[gold]
			)
		)
		(
			sys-devel/clang:11
			!clang? ( sys-devel/llvm:11 )
			clang? (
				=sys-devel/lld-11*
				sys-devel/llvm:11[gold]
			)
		)
	)
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/firefox-${PV}"
MOZJS_BUILDDIR="${S}/jsobj"

pkg_pretend() {
	if use test ; then
		CHECKREQS_DISK_BUILD="6G"
	else
		CHECKREQS_DISK_BUILD="5G"
	fi

	check-reqs_pkg_pretend
}

pkg_setup() {
	if use test ; then
		CHECKREQS_DISK_BUILD="6G"
	else
		CHECKREQS_DISK_BUILD="5G"
	fi

	check-reqs_pkg_setup
}

src_prepare() {
	rm "${WORKDIR}"/firefox/2013_avoid_noinline_on_GCC_with_skcms.patch
	rm "${WORKDIR}"/firefox/2015_fix_cssparser.patch
	rm "${WORKDIR}"/firefox/2016_set_CARGO_PROFILE_RELEASE_LTO.patch
	eapply "${WORKDIR}"/firefox
	eapply "${WORKDIR}"/spidermonkey-patches

	eapply_user

	if [[ ${CHOST} == *-freebsd* ]]; then
		# Don't try to be smart, this does not work in cross-compile anyway
		ln -sfn "${MOZJS_BUILDDIR}/config/Linux_All.mk" "${S}/config/$(uname -s)$(uname -r).mk" || die
	fi

	cd "${S}"/js/src || die
	eautoconf old-configure.in
	eautoconf

	# remove options that are not correct from js-config
	sed '/lib-filenames/d' -i "${S}"/js/src/build/js-config.in || die "failed to remove invalid option from js-config"

	# there is a default config.cache that messes everything up
	rm -f "${S}"/js/src/config.cache || die

	mkdir -p "${MOZJS_BUILDDIR}" || die
}

src_configure() {
	cd "${MOZJS_BUILDDIR}" || die

	${S}/js/src/configure \
		--host="${CBUILD:-${CHOST}}" \
		--target="${CHOST}" \
		--prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--disable-jemalloc \
		--enable-readline \
		--with-system-nspr \
		--with-system-zlib \
		--disable-optimize \
		--with-intl-api \
		--with-toolchain-prefix="${CHOST}-" \
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
	default

	# fix soname links
	pushd "${ED}"/usr/$(get_libdir) &>/dev/null || die
	mv lib${MY_PN}-${MY_MAJOR}.so lib${MY_PN}-${MY_MAJOR}.so.0.0.0 || die
	ln -s lib${MY_PN}-${MY_MAJOR}.so.0.0.0 lib${MY_PN}-${MY_MAJOR}.so.0 || die
	ln -s lib${MY_PN}-${MY_MAJOR}.so.0 lib${MY_PN}-${MY_MAJOR}.so || die
	popd &>/dev/null || die

	# remove unneeded files
	rm \
		"${ED}"/usr/bin/js${MY_MAJOR}-config \
		"${ED}"/usr/$(get_libdir)/libjs_static.ajs \
		|| die

	# fix permissions
	chmod -x \
		"${ED}"/usr/$(get_libdir)/pkgconfig/*.pc \
		"${ED}"/usr/include/mozjs-${MY_MAJOR}/js-config.h \
		|| die

	if ! use minimal; then
		if use jit; then
			pax-mark m "${ED}"usr/bin/js${SLOT%/*}
		fi
	else
		rm -f "${ED}"usr/bin/js${SLOT%/*}
	fi

	# We can't actually disable building of static libraries
	# They're used by the tests and in a few other places
	find "${D}" -iname '*.a' -o -iname '*.ajs' -delete || die
}
