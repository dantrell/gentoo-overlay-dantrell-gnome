# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson xdg

DESCRIPTION="Build molecules, from simple inorganic to extremely complex organic ones"
HOMEPAGE="https://wiki.gnome.org/Apps/Atomix"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE=""

RDEPEND="
	>=x11-libs/gtk+-3.10:3
	>=x11-libs/gdk-pixbuf-2.0.5:2
	>=dev-libs/glib-2.36.0:2
	dev-libs/libgnome-games-support:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.34.0-fnocommon.patch
)
