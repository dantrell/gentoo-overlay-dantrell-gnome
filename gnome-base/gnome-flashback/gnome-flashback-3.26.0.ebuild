# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="GNOME Flashback session and helper application"
HOMEPAGE="https://git.gnome.org/browse/gnome-flashback"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=app-i18n/ibus-1.5.2
	>=dev-libs/glib-2.44.0
	>=gnome-base/gnome-desktop-3.12:3=
	>=media-libs/libcanberra-0.13
	>=media-sound/pulseaudio-2
	>=net-wireless/gnome-bluetooth-3.22.0
	>=sys-auth/polkit-0.97
	>=sys-power/upower-0.99:=
	>=x11-libs/gtk+-3.19.5:3
	>=x11-wm/metacity-3.26.0

	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbfile
	x11-misc/xkeyboard-config
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
"
