# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="Image viewer and browser for Gnome"
HOMEPAGE="https://wiki.gnome.org/Apps/gthumb"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="cdr debug exif gnome-keyring gstreamer http jpeg json lcms raw slideshow svg tiff test webkit webp"

RDEPEND="
	>=dev-libs/glib-2.36.0:2[dbus]
	>=x11-libs/gtk+-3.10.0:3
	exif? ( >=media-gfx/exiv2-0.21:= )
	slideshow? (
		>=media-libs/clutter-1.12.0:1.0
		>=media-libs/clutter-gtk-1:1.0 )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0 )
	raw? ( >=media-libs/libraw-0.14:= )
	http? ( >=net-libs/libsoup-2.42.0:2.4 )
	gnome-keyring? ( >=app-crypt/libsecret-0.11 )
	cdr? ( >=app-cdr/brasero-3.2 )
	svg? ( >=gnome-base/librsvg-2.34:2 )
	webp? ( >=media-libs/libwebp-0.2.0 )
	json? ( >=dev-libs/json-glib-0.15.0 )
	webkit? ( >=net-libs/webkit-gtk-1.10.0:4 )
	lcms? ( >=media-libs/lcms-2.6:2 )

	media-libs/libpng:0=
	sys-libs/zlib
	>=gnome-base/gsettings-desktop-schemas-0.1.4
	jpeg? ( virtual/jpeg:0= )
	tiff? ( media-libs/tiff:= )
	!raw? ( media-gfx/dcraw )
"
DEPEND="${RDEPEND}
	app-text/yelp-tools
	>=dev-util/intltool-0.35
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	test? ( ~app-text/docbook-xml-dtd-4.1.2 )
"
# eautoreconf needs:
#	gnome-base/gnome-common

PATCHES=( "${FILESDIR}/${PN}-3.6.2-exiv2-0.27.patch" ) # bug 674092

src_prepare() {
	# Remove unwanted CFLAGS added with USE=debug
	sed -e 's/CFLAGS="$CFLAGS -g -O0 -DDEBUG"//' \
		-i configure.ac -i configure || die

	gnome2_src_prepare
}

src_configure() {
	# Upstream says in configure help that libchamplain support
	# crashes frequently
	gnome2_src_configure \
		--disable-static \
		--disable-libchamplain \
		$(use_enable cdr libbrasero) \
		$(use_enable debug) \
		$(use_enable exif exiv2) \
		$(use_enable gnome-keyring libsecret) \
		$(use_enable gstreamer) \
		$(use_enable http libsoup) \
		$(use_enable jpeg) \
		$(use_enable json libjson-glib) \
		$(use_enable lcms lcms2) \
		$(use_enable raw libraw) \
		$(use_enable slideshow clutter) \
		$(use_enable svg librsvg) \
		$(use_enable test test-suite) \
		$(use_enable tiff) \
		$(use_enable webkit webkit2) \
		$(use_enable webp libwebp)
}
