# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 vala

DESCRIPTION="Library for code common to Gnome games"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libgnome-games-support"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	dev-libs/libgee:0.8=
	>=dev-libs/glib-2.40:2
	>=x11-libs/gtk+-3.16:3
"
DEPEND="${DEPEND}
	$(vala_depend)
	>=dev-util/intltool-0.50.2
	virtual/pkgconfig
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}
