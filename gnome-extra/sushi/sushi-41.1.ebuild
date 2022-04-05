# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson xdg

DESCRIPTION="A quick previewer for Nautilus, the GNOME file manager"
HOMEPAGE="https://gitlab.gnome.org/GNOME/sushi"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="office wayland webkit +X"
REQUIRED_USE="|| ( wayland X )"

# Optional app-office/libreoffice support (OOo to pdf and then preview)
DEPEND="
	media-libs/libepoxy
	>=app-text/evince-3.0[introspection]
	media-libs/freetype:2
	>=x11-libs/gdk-pixbuf-2.23.0[introspection]
	>=dev-libs/glib-2.29.14:2
	media-libs/gstreamer:1.0[introspection]
	media-libs/gst-plugins-base:1.0[introspection]
	>=x11-libs/gtk+-3.13.2:3[introspection,wayland?,X?]
	>=x11-libs/gtksourceview-4.0.3:4[introspection]
	>=media-libs/harfbuzz-0.9.9:=
	>=dev-libs/gobject-introspection-1.54:=
	webkit? ( >=net-libs/webkit-gtk-2.34:4[introspection] )
	>=dev-libs/gjs-1.40
"
RDEPEND="${DEPEND}
	>=gnome-base/nautilus-3.1.90
	media-plugins/gst-plugins-gtk:1.0[wayland?,X?]
	office? ( app-office/libreoffice )
"
BDEPEND="
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	if ! use webkit; then
		# From GNOME Without Systemd:
		eapply "${FILESDIR}"/${PN}-3.38.1-make-webkit-optional.patch
	fi

	xdg_src_prepare
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

	meson_src_configure \
		$(meson_feature wayland) \
		$(meson_feature X X11)
}

src_compile() {
	local -x GST_PLUGIN_SYSTEM_PATH_1_0=
	meson_src_compile
}
