# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2 meson vala

DESCRIPTION="Manages, extracts and handles media art caches"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libmediaart"

LICENSE="LGPL-2.1+"
SLOT="2.0"
KEYWORDS="~*"

IUSE="gtk gtk-doc +introspection qt5 vala"
REQUIRED_USE="
	^^ ( gtk qt5 )
	vala? ( introspection )
"

RDEPEND="
	>=dev-libs/glib-2.38.0:2
	gtk? ( >=x11-libs/gdk-pixbuf-2.12:2 )
	introspection? ( >=dev-libs/gobject-introspection-1.30:= )
	qt5? ( dev-qt/qtgui:5 )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/gobject-introspection-common
	dev-util/gtk-doc
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.9.5-meson-add-introspection-option.patch
	"${FILESDIR}"/${PN}-1.9.5-meson-add-vapi-option.patch
)

src_prepare() {
	default
	use vala && vala_setup
}

src_configure() {
	local image_library
	use gtk && image_library=gdk-pixbuf
	use qt5 && image_library=qt5

	local emesonargs=(
		-Dimage_library=${image_library}
		$(meson_use introspection)
		$(meson_use vala vapi)
		$(meson_use gtk-doc gtk_doc)
	)
	meson_src_configure
}
