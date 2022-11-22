# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2

DESCRIPTION="Search tool for GNOME"
HOMEPAGE="https://wiki.gnome.org/Attic/GnomeUtils https://gitlab.gnome.org/Archive/gnome-search-tool"

LICENSE="GPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	dev-libs/atk
	>=dev-libs/glib-2.30:2
	sys-apps/grep
	x11-libs/gdk-pixbuf
	>=x11-libs/gtk+-3:3[X]
	x11-libs/libICE
	x11-libs/libSM
"
DEPEND="${RDEPEND}
	sys-apps/findutils
	sys-apps/mlocate
"
BDEPEND="
	>=dev-util/intltool-0.40
	dev-util/itstool
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"
