# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# vala and introspection support is broken, bug #468208
VALA_USE_DEPEND=vapigen

inherit autotools gnome2-utils vala

DESCRIPTION="A graph based image processing framework"
HOMEPAGE="https://gegl.org/"
SRC_URI="https://download.gimp.org/pub/${PN}/${PV:0:3}/${P}.tar.bz2"

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
	media-libs/libpng:0=
	sys-libs/zlib
	media-libs/libjpeg-turbo:0=
	>=x11-libs/gdk-pixbuf-2.32:2
	x11-libs/pango
	cairo? ( x11-libs/cairo )
	ffmpeg? ( >=media-video/ffmpeg-2.8:0= )
	introspection? ( >=dev-libs/gobject-introspection-1.32:= )
	lcms? ( >=media-libs/lcms-2.2:2 )
	lensfun? ( >=media-libs/lensfun-0.2.5 )
	openexr? ( media-libs/openexr:= )
	raw? ( >=media-libs/libraw-0.15.4:0= )
	sdl? ( media-libs/libsdl )
	svg? ( >=gnome-base/librsvg-2.14:2 )
	tiff? ( >=media-libs/tiff-4:= )
	umfpack? ( sci-libs/umfpack )
	v4l? ( >=media-libs/libv4l-1.0.1 )
	webp? ( media-libs/libwebp )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-lang/perl
	>=dev-build/gtk-doc-am-1
	>=dev-util/intltool-0.40.1
	>=dev-build/libtool-2.2
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	default

	# fix OSX loadable module filename extension
	sed -i -e 's/\.dylib/.bundle/' configure.ac || die

	# don't require Apple's OpenCL on versions of OSX that don't have it
	if [[ ${CHOST} == *-darwin* && ${CHOST#*-darwin} -le 9 ]] ; then
		sed -i -e 's/#ifdef __APPLE__/#if 0/' gegl/opencl/* || die
	fi

	# https://bugs.gentoo.org/617618
	eapply "${FILESDIR}"/${P}-g_log_domain.patch

	eapply "${FILESDIR}"/${P}-implicit-declaration.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/geg/-/commit/0703b6b38f4e6cf8ecc623c09c05ef73c6424ee4
	eapply "${FILESDIR}"/${PN}-0.4.16-tools-port-exp-combine-to-use-gexiv2-instead-of-exiv2-directly.patch

	if use openexr && has_version '>=dev-libs/glib-2.67.3'; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/glib/-/issues/2331
		# 	https://bugs.gentoo.org/793998
		eapply "${FILESDIR}"/${PN}-0.4.26-fix-build-glib-2.67.3.patch
	fi

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
		--without-exiv2 \
		--without-gexiv2 \
		--without-graphviz \
		--without-jasper \
		--without-libspiro \
		--without-lua \
		--without-mrg \
		$(use_enable cpu_flags_x86_mmx mmx) \
		$(use_enable cpu_flags_x86_sse sse) \
		$(use_enable debug) \
		$(use_with cairo) \
		$(use_with cairo pangocairo) \
		$(use_with ffmpeg libavformat) \
		$(use_with lcms) \
		$(use_with lensfun) \
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

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
