# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="Beat the odds in a poker-style dice game"
HOMEPAGE="https://wiki.gnome.org/Apps/Tali"

LICENSE="GPL-2+ FDL-1.1+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	dev-libs/glib:2
	>=gnome-base/librsvg-2.32:2
	>=x11-libs/gtk+-3.15:3
"
DEPEND="${RDEPEND}
	dev-libs/appstream-glib
	>=dev-util/intltool-0.50
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"
