# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="GNOME Flashback session and helper application"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-flashback"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~*"

IUSE=""

RDEPEND="
	>=x11-libs/gdk-pixbuf-2.32.2
	>=x11-libs/gtk+-3.22:3
	>=gnome-base/gnome-desktop-3.12:3=
	>=media-libs/libcanberra-0.13
	>=dev-libs/glib-2.44
	>=gnome-base/gsettings-desktop-schemas-3.24
	>=sys-auth/polkit-0.97
	>=app-i18n/ibus-1.5.2
	>=sys-power/upower-0.99:=
	>=x11-libs/libXrandr-1.5.0

	x11-libs/libxcb
	x11-libs/libX11
	>=net-wireless/gnome-bluetooth-3.22.0
	x11-libs/libXext
	>=x11-apps/xinput-1.6.0
	x11-libs/pango
	x11-libs/libxkbfile
	x11-misc/xkeyboard-config
	x11-libs/libXfixes
	>=media-sound/pulseaudio-2

	>=x11-wm/metacity-3.30.0
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
"
