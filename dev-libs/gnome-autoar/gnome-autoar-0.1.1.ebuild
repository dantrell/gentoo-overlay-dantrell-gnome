# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Automatic archives creating and extracting library"
HOMEPAGE="https://git.gnome.org/browse/gnome-autoar/"

LICENSE="GPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/gobject-introspection-0.9.7:=
	>=dev-libs/glib-2.35.6:2
	>=x11-libs/gtk+-3.2:3

	>=app-arch/libarchive-3.2.0:=
"
DEPEND="${DEPEND}
	>=dev-util/gtk-doc-am-1.14
	virtual/pkgconfig
"
