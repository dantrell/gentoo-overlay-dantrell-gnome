# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson virtualx

DESCRIPTION="GtkSourceView-based text editors and IDE helper library"
HOMEPAGE="https://wiki.gnome.org/Projects/Tepl"

LICENSE="LGPL-3+"
SLOT="6"
KEYWORDS="*"

IUSE="gtk-doc +introspection"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.64:2
	>=x11-libs/gtk+-3.22:3[introspection?]
	>=x11-libs/gtksourceview-4.0:4[introspection?]
	>=gui-libs/amtk-5.0:5[introspection?]
	dev-libs/icu:=
	introspection? ( >=dev-libs/gobject-introspection-1.64:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? ( >=dev-util/gtk-doc-1.25
		app-text/docbook-xml-dtd:4.3
	)
	>=sys-devel/gettext-0.19.6
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
