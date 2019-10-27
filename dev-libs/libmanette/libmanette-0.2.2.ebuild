# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson vala

DESCRIPTION="Simple GObject game controller library"
HOMEPAGE="https://gitlab.gnome.org/aplazas/libmanette"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.50:2
	dev-libs/libgudev:=
	>=dev-libs/libevdev-1.4.5
"
DEPEND="${RDEPEND}
	$(vala_depend)
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}
