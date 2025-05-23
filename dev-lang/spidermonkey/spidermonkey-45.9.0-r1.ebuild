# Distributed under the terms of the GNU General Public License v2

EAPI="8"

# Patch version
FIREFOX_PATCHSET="firefox-45.0-patches-12.tar.xz"
SPIDERMONKEY_PATCHSET="spidermonkey-slot45-patches-01.tar.xz"

LLVM_MAX_SLOT=17

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
PYTHON_REQ_USE="ssl,xml(+)"

WANT_AUTOCONF="2.1"

inherit autotools check-reqs flag-o-matic llvm multiprocessing prefix python-any-r1 toolchain-funcs

MY_PN="mozjs"
MY_PV="${PV/_pre*}" # Handle Gentoo pre-releases

MY_MAJOR=$(ver_cut 1)

MOZ_ESR=yes

MOZ_PV=${PV}
MOZ_PV_SUFFIX=
if [[ ${PV} =~ (_(alpha|beta|rc).*)$ ]] ; then
	MOZ_PV_SUFFIX=${BASH_REMATCH[1]}

	# Convert the ebuild version to the upstream Mozilla version
	MOZ_PV="${MOZ_PV/_alpha/a}" # Handle alpha for SRC_URI
	MOZ_PV="${MOZ_PV/_beta/b}"  # Handle beta for SRC_URI
	MOZ_PV="${MOZ_PV%%_rc*}"    # Handle rc for SRC_URI
fi

if [[ -n ${MOZ_ESR} ]] ; then
	# ESR releases have slightly different version numbers
	MOZ_PV="${MOZ_PV}esr"
fi

MOZ_PN="firefox"
MOZ_P="${MOZ_PN}-${MOZ_PV}"
MOZ_PV_DISTFILES="${MOZ_PV}${MOZ_PV_SUFFIX}"
MOZ_P_DISTFILES="${MOZ_PN}-${MOZ_PV_DISTFILES}"

MOZ_SRC_BASE_URI="https://archive.mozilla.org/pub/${MOZ_PN}/releases/${MOZ_PV}"

if [[ ${PV} == *_rc* ]] ; then
	MOZ_SRC_BASE_URI="https://archive.mozilla.org/pub/${MOZ_PN}/candidates/${MOZ_PV}-candidates/build${PV##*_rc}"
fi

PATCH_URIS=(
	http://bloodnoc.org/~roy/olde-distfiles/${FIREFOX_PATCHSET}
	https://dev.gentoo.org/~{anarchy,whissi,polynomial-c,axs}/mozilla/patchsets/${SPIDERMONKEY_PATCHSET}
)

SRC_URI="${MOZ_SRC_BASE_URI}/source/${MOZ_P}.source.tar.xz -> ${MOZ_P_DISTFILES}.source.tar.xz
	${PATCH_URIS[@]}"

DESCRIPTION="SpiderMonkey is Mozilla's JavaScript engine written in C and C++"
HOMEPAGE="https://spidermonkey.dev https://firefox-source-docs.mozilla.org/js/index.html "

LICENSE="MPL-2.0"
SLOT="45/9.0"
KEYWORDS="*"

IUSE="clang cpu_flags_arm_neon debug +jit lto test"

RESTRICT="mirror !test? ( test )"

BDEPEND="${PYTHON_DEPS}
	|| (
		(
			llvm-core/llvm:19
			clang? (
				llvm-core/clang:19
				llvm-core/lld:19
				virtual/rust:0/llvm-19
			)
		)
		(
			llvm-core/llvm:18
			clang? (
				llvm-core/clang:18
				llvm-core/lld:18
				virtual/rust:0/llvm-18
			)
		)
		(
			llvm-core/llvm:17
			clang? (
				llvm-core/clang:17
				llvm-core/lld:17
				virtual/rust:0/llvm-17
			)
		)
		(
			llvm-core/llvm:16
			clang? (
				llvm-core/clang:16
				llvm-core/lld:16
				virtual/rust:0/llvm-16
			)
		)
		(
			llvm-core/llvm:15
			clang? (
				llvm-core/clang:15
				virtual/rust:0/llvm-15
				lto? ( llvm-core/lld:15 )
			)
		)
	)
	!clang? ( virtual/rust )
	virtual/pkgconfig
	test? (
		$(python_gen_any_dep 'dev-python/six[${PYTHON_USEDEP}]')
	)"
DEPEND=">=dev-libs/icu-69.1:=
	dev-libs/nspr
	sys-libs/readline:0=
	sys-libs/zlib"
RDEPEND="${DEPEND}"

S="${WORKDIR}/firefox-${MOZ_PV}/js/src"

llvm_check_deps() {
	if ! has_version -b "llvm-core/llvm:${LLVM_SLOT}" ; then
		einfo "llvm-core/llvm:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	if use clang ; then
		if ! has_version -b "llvm-core/clang:${LLVM_SLOT}" ; then
			einfo "llvm-core/clang:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi

		if ! has_version -b "virtual/rust:0/llvm-${LLVM_SLOT}" ; then
			einfo "virtual/rust:0/llvm-${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi

		if use lto ; then
			if ! has_version -b "llvm-core/lld:${LLVM_SLOT}" ; then
				einfo "llvm-core/lld:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
				return 1
			fi
		fi
	fi

	einfo "Using LLVM slot ${LLVM_SLOT} to build" >&2
}

python_check_deps() {
	if use test ; then
		python_has_version "dev-python/six[${PYTHON_USEDEP}]"
	fi
}

pkg_pretend() {
	if use test ; then
		CHECKREQS_DISK_BUILD="7600M"
	else
		CHECKREQS_DISK_BUILD="6400M"
	fi

	check-reqs_pkg_pretend
}

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary ]] ; then
		if use test ; then
			CHECKREQS_DISK_BUILD="7600M"
		else
			CHECKREQS_DISK_BUILD="6400M"
		fi

		check-reqs_pkg_setup

		llvm_pkg_setup

		if use clang && use lto ; then
			local version_lld=$(ld.lld --version 2>/dev/null | awk '{ print $2 }')
			[[ -n ${version_lld} ]] && version_lld=$(ver_cut 1 "${version_lld}")
			[[ -z ${version_lld} ]] && die "Failed to read ld.lld version!"

			local version_llvm_rust=$(rustc -Vv 2>/dev/null | grep -F -- 'LLVM version:' | awk '{ print $3 }')
			[[ -n ${version_llvm_rust} ]] && version_llvm_rust=$(ver_cut 1 "${version_llvm_rust}")
			[[ -z ${version_llvm_rust} ]] && die "Failed to read used LLVM version from rustc!"

			if ver_test "${version_lld}" -ne "${version_llvm_rust}" ; then
				eerror "Rust is using LLVM version ${version_llvm_rust} but ld.lld version belongs to LLVM version ${version_lld}."
				eerror "You will be unable to link ${CATEGORY}/${PN}. To proceed you have the following options:"
				eerror "  - Manually switch rust version using 'eselect rust' to match used LLVM version"
				eerror "  - Switch to dev-lang/rust[system-llvm] which will guarantee matching version"
				eerror "  - Build ${CATEGORY}/${PN} without USE=lto"
				eerror "  - Rebuild lld with llvm that was used to build rust (may need to rebuild the whole "
				eerror "    llvm/clang/lld/rust chain depending on your @world updates)"
				die "LLVM version used by Rust (${version_llvm_rust}) does not match with ld.lld version (${version_lld})!"
			fi
		fi

		python-any-r1_pkg_setup

		# Build system is using /proc/self/oom_score_adj, bug #604394
		addpredict /proc/self/oom_score_adj

		if ! mountpoint -q /dev/shm ; then
			# If /dev/shm is not available, configure is known to fail with
			# a traceback report referencing /usr/lib/pythonN.N/multiprocessing/synchronize.py
			ewarn "/dev/shm is not mounted -- expect build failures!"
		fi

		# Ensure we use C locale when building, bug #746215
		export LC_ALL=C
	fi
}

src_prepare() {
	pushd ../.. &>/dev/null || die

	eapply "${WORKDIR}"/sm45/${PN}-38-jsapi-tests.patch
	#~eapply "${WORKDIR}"/sm45/mozjs45-1266366.patch
	eapply "${WORKDIR}"/sm45/mozjs38-pkg-config-version.patch
	#~eapply "${WORKDIR}"/sm45/mozilla_configure_regexp_esr.patch
	eapply "${WORKDIR}"/sm45/${PN}-${SLOT%/*}-dont-symlink-non-objfiles.patch
	eapply "${FILESDIR}"/moz38-dont-hardcode-libc-soname.patch

	# apply relevant (modified) patches from gentoo's firefox-45 patchset
	#~rm "${WORKDIR}"/sm45/ff45/8008_nonejit_x86_fix_based_on_bug1253216.patch
	rm "${WORKDIR}"/sm45/ff45/8014_ia64_js.patch
	eapply "${WORKDIR}"/sm45/ff45

	eapply "${FILESDIR}"/spidermonkey-45.9.0-fix-sys-sysctl-h-includes.patch

	default

	# Make cargo respect MAKEOPTS
	export CARGO_BUILD_JOBS="$(makeopts_jobs)"

	# sed-in toolchain prefix
	sed -i \
		-e "s/objdump/${CHOST}-objdump/" \
		python/mozbuild/mozbuild/configure/check_debug_ranges.py \
		|| die "sed failed to set toolchain prefix"

	# use prefix shell in wrapper linker scripts, bug #789660
	hprefixify "${S}"/../../build/cargo-{,host-}linker

	MOZJS_BUILDDIR="${WORKDIR}/build"
	mkdir "${MOZJS_BUILDDIR}" || die

	popd &>/dev/null || die
	eautoconf
}

src_configure() {
	# Show flags set at the beginning
	einfo "Current CFLAGS:    ${CFLAGS}"
	einfo "Current CXXFLAGS:  ${CXXFLAGS}"
	einfo "Current LDFLAGS:   ${LDFLAGS}"
	einfo "Current RUSTFLAGS: ${RUSTFLAGS}"

	local have_switched_compiler=
	if use clang; then
		# Force clang
		einfo "Enforcing the use of clang due to USE=clang ..."
		if tc-is-gcc; then
			have_switched_compiler=yes
		fi
		AR=llvm-ar
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++
		NM=llvm-nm
		RANLIB=llvm-ranlib
	elif ! use clang && ! tc-is-gcc ; then
		# Force gcc
		have_switched_compiler=yes
		einfo "Enforcing the use of gcc due to USE=-clang ..."
		AR=gcc-ar
		CC=${CHOST}-gcc
		CXX=${CHOST}-g++
		NM=gcc-nm
		RANLIB=gcc-ranlib
	fi

	if [[ -n "${have_switched_compiler}" ]] ; then
		# Because we switched active compiler we have to ensure
		# that no unsupported flags are set
		strip-unsupported-flags
	fi

	# Ensure we use correct toolchain
	export HOST_CC="$(tc-getBUILD_CC)"
	export HOST_CXX="$(tc-getBUILD_CXX)"
	export AS="$(tc-getCC) -c"
	tc-export CC CXX LD AR AS NM OBJDUMP RANLIB PKG_CONFIG

	# backup current active Python version
	local PYTHON_OLD=${PYTHON}

	# build system will require Python2.7
	export PYTHON=python2.7

	cd "${MOZJS_BUILDDIR}" || die

	# ../python/mach/mach/mixin/process.py fails to detect SHELL
	export SHELL="${EPREFIX}/bin/bash"

	local -a myeconfargs=(
		--host="${CBUILD:-${CHOST}}"
		--target="${CHOST}"

		--disable-jemalloc
		--disable-optimize
		--disable-strip

		--enable-readline
		--enable-shared-js

		--with-intl-api
		--with-system-icu
		--with-system-nspr
		--with-system-zlib
		--with-toolchain-prefix="${CHOST}-"

		$(use_enable debug)
		$(use_enable jit)
		$(use_enable test tests)
	)

	if ! use x86 && [[ ${CHOST} != armv*h* ]] ; then
		myeconfargs+=( --enable-rust-simd )
	fi

	# Modifications to better support ARM, bug 717344
	if use cpu_flags_arm_neon ; then
		myeconfargs+=( --with-fpu=neon )

		if ! tc-is-clang ; then
			# thumb options aren't supported when using clang, bug 666966
			myeconfargs+=( --with-thumb=yes )
			myeconfargs+=( --with-thumb-interwork=no )
		fi
	fi

	# Tell build system that we want to use LTO
	if use lto ; then
		myeconfargs+=( --enable-lto )

		if use clang ; then
			myeconfargs+=( --enable-linker=lld )
		else
			myeconfargs+=( --enable-linker=gold )
		fi
	fi

	# LTO flag was handled via configure
	filter-flags '-flto*'

	if tc-is-gcc ; then
		if ver_test $(gcc-fullversion) -ge 10 ; then
			einfo "Forcing -fno-tree-loop-vectorize to workaround GCC bug, see bug 758446 ..."
			append-cxxflags -fno-tree-loop-vectorize
		fi
	fi

	# Use system's Python environment
	export MACH_USE_SYSTEM_PYTHON=1
	export PIP_NO_CACHE_DIR=off

	# Show flags we will use
	einfo "Build CFLAGS:    ${CFLAGS}"
	einfo "Build CXXFLAGS:  ${CXXFLAGS}"
	einfo "Build LDFLAGS:   ${LDFLAGS}"
	einfo "Build RUSTFLAGS: ${RUSTFLAGS}"

	# Forcing system-icu allows us to skip patching bundled ICU for PPC
	# and other minor arches
	ECONF_SOURCE="${S}" \
		econf \
		${myeconfargs[@]}

	# restore PYTHON
	export PYTHON=${PYTHON_OLD}
}

src_compile() {
	cd "${MOZJS_BUILDDIR}" || die
	default
}

src_test() {
	if "${MOZJS_BUILDDIR}/js/src/js" -e 'print("Hello world!")'; then
		einfo "Smoke-test successful"
	else
		die "Smoke-test failed: did interpreter initialization fail?"
	fi

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

	# re-slot due to upstream stripping out most of the slotting
	mv "${ED}"/usr/bin/js{,${MY_MAJOR}}-config || die
	mv "${ED}"/usr/bin/js{,${MY_MAJOR}} || die

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
}
