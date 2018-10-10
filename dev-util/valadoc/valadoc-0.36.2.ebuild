# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 vala

DESCRIPTION="A command line tool that generates Vala programming documentation"
HOMEPAGE="https://wiki.gnome.org/Projects/Valadoc"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

DEPEND="
	>=dev-lang/vala-0.19.0
	>=dev-libs/libgee-0.19.91
	>=media-gfx/graphviz-2.16
	>=dev-libs/glib-2.24.0:2
"
RDEPEND="${DEPEND}
	x11-libs/gdk-pixbuf:2
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}
