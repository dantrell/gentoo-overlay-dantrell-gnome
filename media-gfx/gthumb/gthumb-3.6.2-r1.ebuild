# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="Image viewer and browser for Gnome"
HOMEPAGE="https://wiki.gnome.org/Apps/Gthumb"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="cdr colord debug exif gnome-keyring gstreamer http jpeg json lcms raw slideshow svg tiff test webkit webp"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.36.0:2[dbus]
	>=x11-libs/gtk+-3.16.0:3
	exif? ( >=media-gfx/exiv2-0.21:= )
	slideshow? (
		>=media-libs/clutter-1.12.0:1.0
		>=media-libs/clutter-gtk-1:1.0 )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
		media-plugins/gst-plugins-gtk:1.0 )
	raw? ( >=media-libs/libraw-0.14:=
		<media-libs/libraw-0.21 )
	http? ( >=net-libs/libsoup-2.42.0:2.4 )
	gnome-keyring? ( >=app-crypt/libsecret-0.11 )
	cdr? ( >=app-cdr/brasero-3.2 )
	svg? ( >=gnome-base/librsvg-2.34:2 )
	webp? ( >=media-libs/libwebp-0.2.0 )
	json? ( >=dev-libs/json-glib-0.15.0 )
	webkit? ( >=net-libs/webkit-gtk-1.10.0:4 )
	lcms? ( >=media-libs/lcms-2.6:2 )
	colord? ( >=x11-misc/colord-1.3
		>=media-libs/lcms-2.6:2 )

	media-libs/libpng:0=
	sys-libs/zlib
	>=gnome-base/gsettings-desktop-schemas-0.1.4
	jpeg? ( media-libs/libjpeg-turbo:0= )
	tiff? ( media-libs/tiff:= )
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.50.1
	dev-util/itstool
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	test? ( ~app-text/docbook-xml-dtd-4.1.2 )
"
# eautoreconf needs:
#	gnome-base/gnome-common

PATCHES=(
	# From Gentoo:
	# 	https://bugs.gentoo.org/674092
	"${FILESDIR}"/${PN}-3.6.2-exiv2-0.27.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gthumb/-/commit/5bc151d4cf1b42cb42a846d946bd51ae32a510e0
	# 	https://gitlab.gnome.org/GNOME/gthumb/-/commit/6e56da85c9ad12b3c24071db17377e6cdc11efe6
	# 	https://gitlab.gnome.org/GNOME/gthumb/-/commit/4faa5ce2358812d23a1147953ee76f59631590ad
	"${FILESDIR}"/${PN}-3.9.1-jpeg-loader-crash-when-the-original-size-is-too-big-for-a-cairo-surface.patch
	"${FILESDIR}"/${PN}-3.9.1-jpeg-loader-error-if-the-orientation-swaps-width-and-height.patch
	"${FILESDIR}"/${PN}-3.9.1-jpeg-loader-do-not-scan-more-than-output-height-lines.patch
)

src_prepare() {
	# Remove unwanted CFLAGS added with USE=debug
	sed -e 's/CFLAGS="$CFLAGS -g -O0 -DDEBUG"//' \
		-i configure.ac -i configure || die

	gnome2_src_prepare
}

src_configure() {
	# Upstream says in configure help that libchamplain support
	# crashes frequently
	local myeconfargs=(
		--disable-static
		--disable-libchamplain
		$(use_enable cdr libbrasero)
		$(use_enable colord)
		$(use_enable debug)
		$(use_enable exif exiv2)
		$(use_enable gnome-keyring libsecret)
		$(use_enable gstreamer)
		$(use_enable http libsoup)
		$(use_enable jpeg)
		$(use_enable json libjson-glib)
		$(use_enable raw libraw)
		$(use_enable slideshow clutter)
		$(use_enable svg librsvg)
		$(use_enable test test-suite)
		$(use_enable tiff)
		$(use_enable webkit webkit2)
		$(use_enable webp libwebp)
	)
	# colord pulls in lcms2 anyway, so enable lcms with USE="colord -lcms"; some of upstream HAVE_COLORD code depends on HAVE_LCMS2
	if use lcms || use colord; then
		myeconfargs+=( --enable-lcms2 )
	else
		myeconfargs+=( --disable-lcms2 )
	fi
	gnome2_src_configure "${myeconfargs[@]}"
}
