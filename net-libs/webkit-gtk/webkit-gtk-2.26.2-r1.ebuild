# Distributed under the terms of the GNU General Public License v2

EAPI="6"
CMAKE_MAKEFILE_GENERATOR="ninja"
PYTHON_COMPAT=( python{3_5,3_6,3_7,3_8} )
USE_RUBY="ruby24 ruby25 ruby26 ruby27"
CMAKE_MIN_VERSION=3.10

inherit check-reqs cmake-utils flag-o-matic gnome2 pax-utils python-any-r1 ruby-single toolchain-funcs virtualx

MY_P="webkitgtk-${PV}"
DESCRIPTION="Open source web browser engine"
HOMEPAGE="https://www.webkitgtk.org"
SRC_URI="https://www.webkitgtk.org/releases/${MY_P}.tar.xz"

LICENSE="LGPL-2+ BSD"
SLOT="4/37" # soname version of libwebkit2gtk-4.0
KEYWORDS="~*"

IUSE="aqua coverage deprecated doc +egl embedded +geolocation gles2 gnome-keyring +gstreamer +introspection +jit jpeg2k +jumbo-build libnotify +opengl seccomp spell wayland +webgl +X"
# webgl needs gstreamer, bug #560612
# gstreamer with opengl/gles2 needs egl
REQUIRED_USE="
	geolocation? ( introspection )
	gles2? ( egl !opengl )
	gstreamer? ( opengl? ( egl ) )
	opengl? ( webgl )
	webgl? ( gstreamer
		|| ( gles2 opengl ) )
	wayland? ( egl )
	|| ( aqua wayland X )
"

# Tests fail to link for inexplicable reasons
# https://bugs.webkit.org/show_bug.cgi?id=148210
RESTRICT="test"

# Aqua support in gtk3 is untested
# Dependencies found at Source/cmake/OptionsGTK.cmake
# Missing OpenWebRTC checks and conditionals, but ENABLE_MEDIA_STREAM/ENABLE_WEB_RTC is experimental upstream (PRIVATE OFF)
# >=gst-plugins-opus-1.14.4-r1 for opusparse (required by MSE)
RDEPEND="
	>=x11-libs/cairo-1.16.0:=[X?]
	>=media-libs/fontconfig-2.8.0:1.0
	>=media-libs/freetype-2.9.0:2
	>=dev-libs/libgcrypt-1.7.0:0=
	x11-libs/gtk+:3=
	>=x11-libs/gtk+-3.14:3[aqua?,introspection?,wayland?,X?]
	>=media-libs/harfbuzz-1.4.2:=[icu(+)]
	>=dev-libs/icu-3.8.1-r1:=
	virtual/jpeg:0=
	>=net-libs/libsoup-2.48:2.4[introspection?]
	>=dev-libs/libxml2-2.8.0:2
	>=media-libs/libpng-1.4:0=
	dev-db/sqlite:3=
	sys-libs/zlib:0
	>=dev-libs/atk-2.8.0
	media-libs/libwebp:=

	>=dev-libs/glib-2.40:2
	>=dev-libs/libxslt-1.1.7
	media-libs/woff2
	gnome-keyring? ( app-crypt/libsecret )
	introspection? ( >=dev-libs/gobject-introspection-1.32.0:= )
	dev-libs/libtasn1:=
	spell? ( >=app-text/enchant-0.22:0= )
	gstreamer? (
		>=media-libs/gstreamer-1.14:1.0
		>=media-libs/gst-plugins-base-1.14:1.0[egl?,gles2?,opengl?]
		>=media-plugins/gst-plugins-opus-1.14.4-r1:1.0
		>=media-libs/gst-plugins-bad-1.14:1.0 )

	X? (
		x11-libs/libX11
		x11-libs/libXcomposite
		x11-libs/libXdamage
		x11-libs/libXrender
		x11-libs/libXt )

	libnotify? ( x11-libs/libnotify )
	dev-libs/hyphen
	jpeg2k? ( >=media-libs/openjpeg-2.2.0:2= )

	egl? ( media-libs/mesa[egl] )
	embedded? (
		>=gui-libs/libwpe-1.3.0:1.0
		>=gui-libs/wpebackend-fdo-1.3.1:1.0
	)
	gles2? ( media-libs/mesa[gles2] )
	opengl? ( virtual/opengl )
	webgl? (
		x11-libs/libXcomposite
		x11-libs/libXdamage )

	seccomp? (
		>=sys-apps/bubblewrap-0.3.1
		sys-libs/libseccomp
		sys-apps/xdg-dbus-proxy
	)
"

# paxctl needed for bug #407085
# Need real bison, not yacc
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	${RUBY_DEPS}
	>=app-accessibility/at-spi2-core-2.5.3
	>=dev-util/gtk-doc-am-1.10
	>=dev-util/gperf-3.0.1
	>=sys-devel/bison-2.4.3
	|| ( >=sys-devel/gcc-7.3 >=sys-devel/clang-3.3 )
	sys-devel/gettext
	virtual/pkgconfig

	>=dev-lang/perl-5.10
	virtual/perl-Data-Dumper
	virtual/perl-Carp
	virtual/perl-JSON-PP

	doc? ( >=dev-util/gtk-doc-1.10 )
	geolocation? ( dev-util/gdbus-codegen )
	introspection? ( jit? ( sys-apps/paxctl ) )
"
#	test? (
#		dev-python/pygobject:3[python_targets_python2_7]
#		x11-themes/hicolor-icon-theme
#		jit? ( sys-apps/paxctl ) )
RDEPEND="${RDEPEND}
	geolocation? ( >=app-misc/geoclue-2.1.5:2.0 )
"

S="${WORKDIR}/${MY_P}"

CHECKREQS_DISK_BUILD="18G" # and even this might not be enough, bug #417307

pkg_pretend() {
	if [[ ${MERGE_TYPE} != "binary" ]] ; then
		if is-flagq "-g*" && ! is-flagq "-g*0" ; then
			einfo "Checking for sufficient disk space to build ${PN} with debugging CFLAGS"
			check-reqs_pkg_pretend
		fi

		if ! test-flag-CXX -std=c++17 ; then
			die "You need at least GCC 7.3.x or Clang >= 5 for C++17-specific compiler flags"
		fi

		if tc-is-gcc && [[ $(gcc-version) < 7.3 ]] ; then
			die 'The active compiler needs to be gcc 7.3 (or newer)'
		fi
	fi

	if ! use opengl && ! use gles2; then
		ewarn
		ewarn "You are disabling OpenGL usage (USE=opengl or USE=gles) completely."
		ewarn "This is an unsupported configuration meant for very specific embedded"
		ewarn "use cases, where there truly is no GL possible (and even that use case"
		ewarn "is very unlikely to come by). If you have GL (even software-only), you"
		ewarn "really really should be enabling OpenGL!"
		ewarn
	fi
}

pkg_setup() {
	if [[ ${MERGE_TYPE} != "binary" ]] && is-flagq "-g*" && ! is-flagq "-g*0" ; then
		check-reqs_pkg_setup
	fi

	python-any-r1_pkg_setup
}

src_prepare() {
	if use deprecated; then
		# From WebKit:
		# 	https://bugs.webkit.org/show_bug.cgi?id=199094
		eapply "${FILESDIR}"/${PN}-2.26.1-restore-preprocessor-guards.patch
	fi

	eapply "${FILESDIR}"/${PN}-2.24.4-icu-65.patch # bug 698596
	eapply "${FILESDIR}"/${PN}-2.24.4-eglmesaext-include.patch # bug 699054 # https://bugs.webkit.org/show_bug.cgi?id=204108
	cmake-utils_src_prepare
	gnome2_src_prepare
}

src_configure() {
	# Respect CC, otherwise fails on prefix #395875
	tc-export CC

	# Arches without JIT support also need this to really disable it in all places
	use jit || append-cppflags -DENABLE_JIT=0 -DENABLE_YARR_JIT=0 -DENABLE_ASSEMBLER=0 -DENABLE_C_LOOP=1

	# It does not compile on alpha without this in LDFLAGS
	# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=648761
	use alpha && append-ldflags "-Wl,--no-relax"

	# ld segfaults on ia64 with LDFLAGS --as-needed, bug #555504
	use ia64 && append-ldflags "-Wl,--no-as-needed"

	# Sigbuses on SPARC with mcpu and co., bug #???
	use sparc && filter-flags "-mvis"

	# https://bugs.webkit.org/show_bug.cgi?id=42070 , #301634
	use ppc64 && append-flags "-mminimal-toc"

	# Try to use less memory, bug #469942 (see Fedora .spec for reference)
	# --no-keep-memory doesn't work on ia64, bug #502492
	if ! use ia64; then
		append-ldflags "-Wl,--no-keep-memory"
	fi

	# We try to use gold when possible for this package
#	if ! tc-ld-is-gold ; then
#		append-ldflags "-Wl,--reduce-memory-overheads"
#	fi

	# Multiple rendering bugs on youtube, github, etc without this, bug #547224
	append-flags $(test-flags -fno-strict-aliasing)

	# Ruby situation is a bit complicated. See bug 513888
	local rubyimpl
	local ruby_interpreter=""
	for rubyimpl in ${USE_RUBY}; do
		if has_version "virtual/rubygems[ruby_targets_${rubyimpl}]"; then
			ruby_interpreter="-DRUBY_EXECUTABLE=$(type -P ${rubyimpl})"
		fi
	done
	# This will rarely occur. Only a couple of corner cases could lead us to
	# that failure. See bug 513888
	[[ -z $ruby_interpreter ]] && die "No suitable ruby interpreter found"

	# TODO: Check Web Audio support
	# should somehow let user select between them?
	#
	# FTL_JIT requires llvm
	#
	# opengl needs to be explicetly handled, bug #576634

	local opengl_enabled
	if use opengl || use gles2; then
		opengl_enabled=ON
	else
		opengl_enabled=OFF
	fi

	local c_loop_enabled
	if use jit; then
		loop_c_enabled=OFF
	else
		loop_c_enabled=ON
	fi

	local datalist_enabled
	if ! use deprecated; then
		datalist_enabled=ON
	else
		datalist_enabled=OFF
	fi

	local mycmakeargs=(
		-DENABLE_UNIFIED_BUILDS=$(usex jumbo-build)
		-DENABLE_QUARTZ_TARGET=$(usex aqua)
		-DENABLE_API_TESTS=$(usex test)
		-DENABLE_GTKDOC=$(usex doc)
		-DENABLE_GEOLOCATION=$(usex geolocation) # Runtime optional (talks over dbus service)
		$(cmake-utils_use_find_package gles2 OpenGLES2)
		-DENABLE_GLES2=$(usex gles2)
		-DENABLE_VIDEO=$(usex gstreamer)
		-DENABLE_WEB_AUDIO=$(usex gstreamer)
		-DENABLE_INTROSPECTION=$(usex introspection)
		-DENABLE_JIT=$(usex jit)
		-DENABLE_SAMPLING_PROFILER=$(usex jit)
		-DUSE_LIBNOTIFY=$(usex libnotify)
		-DUSE_LIBSECRET=$(usex gnome-keyring)
		-DUSE_OPENJPEG=$(usex jpeg2k)
		-DUSE_WOFF2=ON
		-DENABLE_SPELLCHECK=$(usex spell)
		-DENABLE_WAYLAND_TARGET=$(usex wayland)
		-DUSE_WPE_RENDERER=$(usex embedded)
		-DENABLE_WEBGL=$(usex webgl)
		$(cmake-utils_use_find_package egl EGL)
		$(cmake-utils_use_find_package opengl OpenGL)
		-DENABLE_X11_TARGET=$(usex X)
		-DENABLE_OPENGL=${opengl_enabled}
		-DENABLE_BUBBLEWRAP_SANDBOX=$(usex seccomp)
		-DBWRAP_EXECUTABLE="${EPREFIX}"/usr/bin/bwrap # If bubblewrap[suid] then portage makes it go-r and cmake find_program fails with that
		-DENABLE_C_LOOP=${loop_c_enabled}
		-DCMAKE_BUILD_TYPE=Release
		-DPORT=GTK
		-DENABLE_MEDIA_SOURCE=OFF
		-DENABLE_DATALIST_ELEMENT=${datalist_enabled}
		${ruby_interpreter}
	)

	# Allow it to use GOLD when possible as it has all the magic to
	# detect when to use it and using gold for this concrete package has
	# multiple advantages and is also the upstream default, bug #585788
#	if tc-ld-is-gold ; then
#		mycmakeargs+=( -DUSE_LD_GOLD=ON )
#	else
#		mycmakeargs+=( -DUSE_LD_GOLD=OFF )
#	fi

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_test() {
	# Prevents test failures on PaX systems
	use jit && pax-mark m $(list-paxables Programs/*[Tt]ests/*) # Programs/unittests/.libs/test*

	cmake-utils_src_test
}

src_install() {
	cmake-utils_src_install

	# Prevents crashes on PaX systems, bug #522808
	use jit && pax-mark m "${ED}usr/libexec/webkit2gtk-4.0/jsc" "${ED}usr/libexec/webkit2gtk-4.0/WebKitWebProcess"
	pax-mark m "${ED}usr/libexec/webkit2gtk-4.0/WebKitPluginProcess"
}
