# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2

DESCRIPTION="Actions, Menus and Toolbars Kit for GTK+ applications"
HOMEPAGE="https://wiki.gnome.org/Projects/Amtk https://gitlab.gnome.org/World/amtk"

LICENSE="LGPL-2.1+"
SLOT="5"
KEYWORDS="*"

IUSE="+introspection"

RDEPEND="
	>=dev-libs/glib-2.52:2
	>=x11-libs/gtk+-3.22:3
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=sys-devel/gettext-0.19.6
	>=dev-build/gtk-doc-am-1.25
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		--disable-gtk-doc \
		--disable-installed-tests \
		$(use_enable introspection) \
		--disable-valgrind
}
