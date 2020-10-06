# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson virtualx

DESCRIPTION="GtkSourceView-based text editors and IDE helper library"
HOMEPAGE="https://wiki.gnome.org/Projects/Tepl"

LICENSE="LGPL-2.1+"
SLOT="5"
KEYWORDS="~*"

IUSE="gtk-doc +introspection"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.52:2
	>=x11-libs/gtk+-3.22:3[introspection?]
	>=x11-libs/gtksourceview-4.0:4[introspection?]
	>=gui-libs/amtk-5.0:5[introspection?]
	>=dev-libs/libxml2-2.5:2
	app-i18n/uchardet
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.6
	gtk-doc? ( >=dev-util/gtk-doc-am-1.25 )
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		$(meson_use gtk-doc gtk_doc)
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}
