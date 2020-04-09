# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson vala virtualx

DESCRIPTION="A cheesy program to take pictures and videos from your webcam"
HOMEPAGE="https://wiki.gnome.org/Apps/Cheese"

LICENSE="GPL-2+"
SLOT="0/8" # subslot = libcheese soname version
KEYWORDS="*"

IUSE="+introspection gtk-doc test"

RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.39.90:2
	>=x11-libs/gtk+-3.13.4:3[introspection?]
	>=gnome-base/gnome-desktop-2.91.6:3=
	>=media-libs/libcanberra-0.26[gtk3]
	>=media-libs/clutter-1.13.2:1.0[introspection?]
	>=media-libs/clutter-gtk-0.91.8:1.0
	media-libs/clutter-gst:3.0
	media-libs/cogl:1.0=[introspection?]

	media-video/gnome-video-effects
	x11-libs/gdk-pixbuf:2[jpeg,introspection?]
	x11-libs/libX11
	x11-libs/libXtst

	>=media-libs/gstreamer-1.4:1.0[introspection?]
	>=media-libs/gst-plugins-base-1.4:1.0[introspection?,ogg,pango,theora,vorbis,X]

	introspection? ( >=dev-libs/gobject-introspection-0.6.7:= )
"
RDEPEND="${COMMON_DEPEND}
	>=media-libs/gst-plugins-bad-1.4:1.0
	>=media-libs/gst-plugins-good-1.4:1.0

	>=media-plugins/gst-plugins-jpeg-1.4:1.0
	>=media-plugins/gst-plugins-v4l2-1.4:1.0
	>=media-plugins/gst-plugins-vpx-1.4:1.0
"
# libxml2+gdk-pixbuf required for glib-compile-resources
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.3
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.14
	>=dev-util/intltool-0.50
	dev-util/itstool
	virtual/pkgconfig
	x11-base/xorg-proto
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	# Prevent sandbox violations when we need write access to
	# /dev/dri/card* in its init phase, bug #358755
	for card in /dev/dri/card* ; do
		addpredict "${card}"
	done

	# Prevent sandbox violations when we need write access to
	# /dev/dri/render* in its init phase, bug #358755
	for render in /dev/dri/render* ; do
		addpredict "${render}"
	done

	local emesonargs=(
		$(meson_use test tests)
		$(meson_use introspection)
		$(meson_use gtk-doc gtk_doc)
		-D man=false
	)
	meson_src_configure
}

src_test() {
	"${EROOT}${GLIB_COMPILE_SCHEMAS}" --allow-any-name "${S}/data" || die
	GSETTINGS_SCHEMA_DIR="${S}/data" virtx meson_src_test
}
