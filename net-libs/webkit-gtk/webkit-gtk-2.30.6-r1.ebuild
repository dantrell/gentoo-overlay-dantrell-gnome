# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_REQ_USE="xml(+)"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
USE_RUBY="ruby27 ruby30 ruby31 ruby32"

inherit check-reqs cmake flag-o-matic gnome2 pax-utils python-any-r1 ruby-single toolchain-funcs virtualx

MY_P="webkitgtk-${PV}"
DESCRIPTION="Open source web browser engine"
HOMEPAGE="https://www.webkitgtk.org"
SRC_URI="https://www.webkitgtk.org/releases/${MY_P}.tar.xz"

LICENSE="LGPL-2+ BSD"
SLOT="4/37" # soname version of libwebkit2gtk-4.0
KEYWORDS="*"

IUSE="aqua +egl examples gamepad +geolocation gles2-only gnome-keyring +gstreamer gtk-doc +introspection +jpeg2k +jumbo-build libnotify +opengl seccomp spell systemd wayland +X"

# gstreamer with opengl/gles2 needs egl
REQUIRED_USE="
	geolocation? ( introspection )
	gles2-only? ( egl !opengl )
	gstreamer? ( opengl? ( egl ) )
	wayland? ( egl )
	|| ( aqua wayland X )
"

# Tests fail to link for inexplicable reasons
# https://bugs.webkit.org/show_bug.cgi?id=148210
RESTRICT="test"

# Aqua support in gtk3 is untested
# Dependencies found at Source/cmake/OptionsGTK.cmake
# Various compile-time optionals for gtk+-3.22.0 - ensure it
# Missing WebRTC support, but ENABLE_MEDIA_STREAM/ENABLE_WEB_RTC is experimental upstream (PRIVATE OFF) and shouldn't be used yet in 2.30
# >=gst-plugins-opus-1.14.4-r1 for opusparse (required by MSE)
wpe_depend="
	>=gui-libs/libwpe-1.5.0:1.0
	>=gui-libs/wpebackend-fdo-1.7.0:1.0
"
# TODO: gst-plugins-base[X] is only needed when build configuration ends up with GLX set, but that's a bit automagic too to fix
RDEPEND="
	>=x11-libs/cairo-1.14.0:=[X?]
	>=media-libs/fontconfig-2.8.0:1.0
	>=media-libs/freetype-2.4.2:2
	>=dev-libs/libgcrypt-1.6.0:0=
	x11-libs/gtk+:3=
	>=x11-libs/gtk+-3.22.0:3[aqua?,introspection?,wayland?,X?]
	>=media-libs/harfbuzz-0.9.18:=[icu(+)]
	>=dev-libs/icu-60.2:=
	media-libs/libjpeg-turbo:0=
	>=net-libs/libsoup-2.54:2.4[introspection?]
	>=dev-libs/libxml2-2.8.0:2
	>=media-libs/libpng-1.4:0=
	dev-db/sqlite:3=
	sys-libs/zlib:0
	|| ( >=app-accessibility/at-spi2-core-2.46.0:2 >=dev-libs/atk-2.16.0 )
	media-libs/libwebp:=

	>=dev-libs/glib-2.44.0:2
	>=dev-libs/libxslt-1.1.7
	media-libs/woff2
	gnome-keyring? ( app-crypt/libsecret )
	introspection? ( >=dev-libs/gobject-introspection-1.0:= )
	dev-libs/libtasn1:=
	spell? ( >=app-text/enchant-0.22:2 )
	gstreamer? (
		>=media-libs/gstreamer-1.14:1.0
		>=media-libs/gst-plugins-base-1.14:1.0[egl?,opengl?,X?]
		gles2-only? ( media-libs/gst-plugins-base:1.0[gles2] )
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

	egl? ( media-libs/mesa[egl(+)] )
	gles2-only? ( media-libs/mesa[gles2] )
	opengl? ( virtual/opengl )
	wayland? (
		dev-libs/wayland
		>=dev-libs/wayland-protocols-1.12
		opengl? ( ${wpe_depend} )
		gles2-only? ( ${wpe_depend} )
	)

	seccomp? (
		>=sys-apps/bubblewrap-0.3.1
		sys-libs/libseccomp
		sys-apps/xdg-dbus-proxy
	)

	systemd? ( sys-apps/systemd:= )
	gamepad? ( >=dev-libs/libmanette-0.2.4 )
"
unset wpe_depend
DEPEND="${RDEPEND}"
# paxctl needed for bug #407085
# Need real bison, not yacc
BDEPEND="
	${PYTHON_DEPS}
	${RUBY_DEPS}
	>=app-accessibility/at-spi2-core-2.5.3
	>=dev-util/gperf-3.0.1
	>=sys-devel/bison-2.4.3
	|| ( >=sys-devel/gcc-7.5 >=llvm-core/clang-5 )
	sys-devel/gettext
	virtual/pkgconfig

	>=dev-lang/perl-5.10
	virtual/perl-Data-Dumper
	virtual/perl-Carp
	virtual/perl-JSON-PP

	gtk-doc? ( >=dev-util/gtk-doc-1.32 )
	geolocation? ( dev-util/gdbus-codegen )
	>=dev-build/cmake-3.10
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
			die "You need at least GCC 7.5.x or Clang >= 5 for C++17-specific compiler flags"
		fi
	fi

	if ! use opengl && ! use gles2-only; then
		ewarn
		ewarn "You are disabling OpenGL usage (USE=opengl or USE=gles2-only) completely."
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
	eapply "${FILESDIR}"/${PN}-2.24.4-eglmesaext-include.patch # bug 699054 # https://bugs.webkit.org/show_bug.cgi?id=204108
	eapply "${FILESDIR}"/${PN}-2.26.3-fix-gtk-doc.patch # bug 704550 - retest without it once we can depend on >=gtk-doc-1.32
	eapply "${FILESDIR}"/${PN}-2.28.2-opengl-without-X-fixes.patch
	eapply "${FILESDIR}"/${PN}-2.28.2-non-jumbo-fix.patch
	eapply "${FILESDIR}"/${PN}-2.28.4-non-jumbo-fix2.patch
	eapply "${FILESDIR}"/${PN}-2.30.3-fix-noGL-build.patch
	cmake_src_prepare
	gnome2_src_prepare
}

src_configure() {
	# Respect CC, otherwise fails on prefix #395875
	tc-export CC

	# It does not compile on alpha without this in LDFLAGS
	# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=648761
	use alpha && append-ldflags "-Wl,--no-relax"

	# Sigbuses on SPARC with mcpu and co., bug #???
	use sparc && filter-flags "-mvis"

	# https://bugs.webkit.org/show_bug.cgi?id=42070 , #301634
	use ppc64 && append-flags "-mminimal-toc"

	# Try to use less memory, bug #469942 (see Fedora .spec for reference)
	append-ldflags "-Wl,--no-keep-memory"

	# Ruby situation is a bit complicated. See bug 513888
	local rubyimpl
	local ruby_interpreter=""
	for rubyimpl in ${USE_RUBY}; do
		if has_version -b "virtual/rubygems[ruby_targets_${rubyimpl}]"; then
			ruby_interpreter="-DRUBY_EXECUTABLE=$(type -P ${rubyimpl})"
		fi
	done
	# This will rarely occur. Only a couple of corner cases could lead us to
	# that failure. See bug 513888
	[[ -z $ruby_interpreter ]] && die "No suitable ruby interpreter found"

	# TODO: Check Web Audio support
	# should somehow let user select between them?

	# opengl needs to be explicetly handled, bug #576634
	local use_wpe_renderer=OFF
	local opengl_enabled
	if use opengl || use gles2-only; then
		opengl_enabled=ON
		use wayland && use_wpe_renderer=ON
	else
		opengl_enabled=OFF
	fi

	local mycmakeargs=(
		${ruby_interpreter}
		$(cmake_use_find_package gles2-only OpenGLES2)
		$(cmake_use_find_package egl EGL)
		$(cmake_use_find_package opengl OpenGL)
		-DBWRAP_EXECUTABLE:FILEPATH="${EPREFIX}"/usr/bin/bwrap # If bubblewrap[suid] then portage makes it go-r and cmake find_program fails with that
		-DDBUS_PROXY_EXECUTABLE:FILEPATH="${EPREFIX}"/usr/bin/xdg-dbus-proxy
		-DPORT=GTK
		# Source/cmake/WebKitFeatures.cmake
		-DENABLE_API_TESTS=$(usex test)
		-DENABLE_BUBBLEWRAP_SANDBOX=$(usex seccomp)
		-DENABLE_GAMEPAD=$(usex gamepad)
		-DENABLE_GEOLOCATION=$(usex geolocation) # Runtime optional (talks over dbus service)
		-DENABLE_MINIBROWSER=$(usex examples)
		-DENABLE_SPELLCHECK=$(usex spell)
		-DENABLE_UNIFIED_BUILDS=$(usex jumbo-build)
		-DENABLE_VIDEO=$(usex gstreamer)
		-DENABLE_WEBGL=${opengl_enabled}
		# Supported only under ANGLE and default off PRIVATE option still@2.34.1, see
		# https://bugs.webkit.org/show_bug.cgi?id=225563
		# https://bugs.webkit.org/show_bug.cgi?id=224888
		-DENABLE_WEBGL2=OFF
		-DENABLE_WEB_AUDIO=$(usex gstreamer)
		# Source/cmake/OptionsGTK.cmake
		-DENABLE_GLES2=$(usex gles2-only)
		-DENABLE_GTKDOC=$(usex gtk-doc)
		-DENABLE_INTROSPECTION=$(usex introspection)
		-DENABLE_QUARTZ_TARGET=$(usex aqua)
		-DENABLE_WAYLAND_TARGET=$(usex wayland)
		-DENABLE_X11_TARGET=$(usex X)
		-DUSE_GTK4=OFF
		-DUSE_LIBHYPHEN=ON
		-DUSE_LIBNOTIFY=$(usex libnotify)
		-DUSE_LIBSECRET=$(usex gnome-keyring)
		-DENABLE_GRAPHICS_CONTEXT_GL=${opengl_enabled}
		-DUSE_OPENJPEG=$(usex jpeg2k)
		-DUSE_SYSTEMD=$(usex systemd) # Whether to enable journald logging
		-DUSE_WOFF2=ON
		-DUSE_WPE_RENDERER=${use_wpe_renderer} # WPE renderer is used to implement accelerated compositing under wayland
		-DCMAKE_BUILD_TYPE=Release
	)

	# https://bugs.gentoo.org/761238
	append-cppflags -DNDEBUG

	# CMake Error at /usr/share/cmake/Modules/FindPackageHandleStandardArgs.cmake:165 (message):
	#   Could NOT find Threads (missing: Threads_FOUND)
	WK_USE_CCACHE=NO cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_test() {
	# Prevents test failures on PaX systems
	pax-mark m $(list-paxables Programs/*[Tt]ests/*) # Programs/unittests/.libs/test*

	cmake_src_test
}

src_install() {
	cmake_src_install

	# Prevents crashes on PaX systems, bug #522808
	pax-mark m "${ED}/usr/libexec/webkit2gtk-4.0/jsc" "${ED}/usr/libexec/webkit2gtk-4.0/WebKitWebProcess"
	pax-mark m "${ED}/usr/libexec/webkit2gtk-4.0/WebKitPluginProcess"
}
