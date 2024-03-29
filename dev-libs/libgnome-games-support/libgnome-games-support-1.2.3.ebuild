# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Library for code common to GNOME games"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libgnome-games-support"

LICENSE="LGPL-3+"
SLOT="1/2"
KEYWORDS="*"

IUSE=""

RDEPEND="
	dev-libs/libgee:0.8=
	>=dev-libs/glib-2.40:2
	>=x11-libs/gtk+-3.19.2:3
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		VALAC=$(type -P true)
}
