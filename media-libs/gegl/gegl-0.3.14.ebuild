# Distributed under the terms of the GNU General Public License v2

EAPI="6"

# vala and introspection support is broken, bug #468208
VALA_USE_DEPEND=vapigen

inherit autotools eutils gnome2-utils ltprune vala versionator

DESCRIPTION="A graph based image processing framework"
HOMEPAGE="https://gegl.org/"
SRC_URI="http://download.gimp.org/pub/${PN}/${PV:0:3}/${P}.tar.bz2"

LICENSE="|| ( GPL-3 LGPL-3 )"
SLOT="0.3"
KEYWORDS="*"

IUSE="cairo cpu_flags_x86_mmx cpu_flags_x86_sse debug ffmpeg +introspection lcms lensfun openexr raw sdl svg tiff umfpack vala v4l webp"
REQUIRED_USE="
	svg? ( cairo )
	vala? ( introspection )
"

RESTRICT="test"

# NOTE: Even current libav 11.4 does not have AV_CODEC_CAP_VARIABLE_FRAME_SIZE
#       so there is no chance to support libav right now (Gentoo bug #567638)
#       If it returns, please check prior GEGL ebuilds for how libav was integrated.  Thanks!
RDEPEND="
	>=dev-libs/glib-2.36:2
	dev-libs/json-glib
	>=media-libs/babl-0.1.24
	sys-libs/zlib
	>=x11-libs/gdk-pixbuf-2.32:2
	x11-libs/pango

	cairo? ( x11-libs/cairo )
	ffmpeg? ( >=media-video/ffmpeg-2.8:0= )
	introspection? ( >=dev-libs/gobject-introspection-1.32:= )
	virtual/jpeg:0=
	lcms? ( >=media-libs/lcms-2.2:2 )
	lensfun? ( >=media-libs/lensfun-0.2.5 )
	openexr? ( media-libs/openexr:= )
	media-libs/libpng:0=
	raw? ( >=media-libs/libraw-0.15.4:0= )
	sdl? ( media-libs/libsdl )
	svg? ( >=gnome-base/librsvg-2.14:2 )
	tiff? ( >=media-libs/tiff-4:0 )
	umfpack? ( sci-libs/umfpack )
	v4l? ( >=media-libs/libv4l-1.0.1 )
	webp? ( media-libs/libwebp )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1
	>=dev-util/intltool-0.40.1
	dev-lang/perl
	virtual/pkgconfig
	>=sys-devel/libtool-2.2
	vala? ( $(vala_depend) )
"

src_prepare() {
	default

	# FIXME: the following should be proper patch sent to upstream
	# fix OSX loadable module filename extension
	sed -i -e 's/\.dylib/.bundle/' configure.ac || die
	# don't require Apple's OpenCL on versions of OSX that don't have it
	if [[ ${CHOST} == *-darwin* && ${CHOST#*-darwin} -le 9 ]] ; then
		sed -i -e 's/#ifdef __APPLE__/#if 0/' gegl/opencl/* || die
	fi

	# https://bugs.gentoo.org/617618
	eapply "${FILESDIR}"/${P}-g_log_domain.patch

	eapply "${FILESDIR}"/${P}-implicit-declaration.patch

	eautoreconf

	gnome2_environment_reset

	use vala && vala_src_prepare
}

src_configure() {
	# never enable altering of CFLAGS via profile option
	# libspiro: not in portage main tree
	# disable documentation as the generating is bit automagic
	#    if anyone wants to work on it just create bug with patch

	# Also please note that:
	#
	#  - Some auto-detections are not patched away since the docs are
	#    not built (--disable-docs, lack of --enable-gtk-doc) and these
	#    tools affect re-generation of docs, only
	#    (e.g. ruby, asciidoc, dot (of graphviz), enscript)
	#
	#  - Parameter --with-exiv2 compiles a noinst-app only, no use
	#
	#  - Parameter --disable-workshop disables any use of Lua, effectivly
	#
	#  - v4l support does not work with our media-libs/libv4l-0.8.9,
	#    upstream bug at https://bugzilla.gnome.org/show_bug.cgi?id=654675
	#
	#  - There are two checks for dot, one controllable by --with(out)-graphviz
	#    which toggles HAVE_GRAPHVIZ that is not used anywhere.  Yes.
	#
	#  - mrg is not in tree and gexiv2 support only has effect when mrg support
	#    is enabled
	#
	# So that's why USE="exif graphviz lua v4l" got resolved.  More at:
	# https://bugs.gentoo.org/451136
	#
	econf \
		--disable-docs \
		--disable-profile \
		--disable-workshop \
		--program-suffix=-${SLOT} \
		--with-gdk-pixbuf \
		--with-pango \
		--without-libspiro \
		$(use_enable cpu_flags_x86_mmx mmx) \
		$(use_enable cpu_flags_x86_sse sse) \
		$(use_enable debug) \
		$(use_with cairo) \
		$(use_with cairo pangocairo) \
		--without-exiv2 \
		$(use_with ffmpeg libavformat) \
		--without-gexiv2 \
		--without-graphviz \
		--without-jasper \
		$(use_with lcms) \
		$(use_with lensfun) \
		--without-lua \
		--without-mrg \
		$(use_with openexr) \
		$(use_with raw libraw) \
		$(use_with sdl) \
		$(use_with svg librsvg) \
		$(use_with tiff libtiff) \
		$(use_with umfpack) \
		$(use_with v4l libv4l) \
		$(use_with v4l libv4l2) \
		$(use_enable introspection) \
		$(use_with vala) \
		$(use_with webp)
}

src_compile() {
	default
}

src_install() {
	default
	prune_libtool_files --all
}
