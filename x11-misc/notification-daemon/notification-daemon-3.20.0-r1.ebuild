# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org

DESCRIPTION="Notification daemon"
HOMEPAGE="https://gitlab.gnome.org/GNOME/notification-daemon"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	>=dev-libs/glib-2.27:2
	>=x11-libs/gtk+-3.19.5:3[X]
	sys-apps/dbus
	x11-libs/libX11
	!x11-misc/notify-osd
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/gdbus-codegen
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
"

src_install() {
	default

	insinto /usr/share/dbus-1/services
	newins <<-EOF - org.freedesktop.Notifications.service
	[D-BUS Service]
	Name=org.freedesktop.Notifications
	Exec=/usr/libexec/notification-daemon
	EOF
}
