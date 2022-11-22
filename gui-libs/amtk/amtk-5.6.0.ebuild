# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2 meson

DESCRIPTION="Actions, Menus and Toolbars Kit for GTK+ applications"
HOMEPAGE="https://wiki.gnome.org/Projects/Amtk https://gitlab.gnome.org/World/amtk"

LICENSE="LGPL-2.1+"
SLOT="5/1"
KEYWORDS="~*"

IUSE="gtk-doc +introspection"

RDEPEND="
	>=dev-libs/glib-2.56:2
	>=x11-libs/gtk+-3.22:3
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? (
		>=dev-util/gtk-doc-1.25
		app-text/docbook-xml-dtd:4.3
	)
	>=sys-devel/gettext-0.19.6
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		$(meson_use gtk-doc gtk_doc)
		$(meson_use introspection gobject_introspection)
	)
	meson_src_configure
}
