# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2

DESCRIPTION="Mouse accessibility enhancements for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Projects/Mousetweaks"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.25.9:2
	>=x11-libs/gtk+-3:3[X]
	>=gnome-base/gsettings-desktop-schemas-0.1

	x11-libs/libX11
	x11-libs/libXtst
	x11-libs/libXfixes
	x11-libs/libXcursor
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"
