# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org

DESCRIPTION="PolicyKit helper to configure cups with fine-grained privileges"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/cups-pk-helper https://gitlab.freedesktop.org/cups-pk-helper/cups-pk-helper"
SRC_URI="https://www.freedesktop.org/software/${PN}/releases/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

RESTRICT="test" # bug #864949

DEPEND="
	>=dev-libs/glib-2.30.0:2
	>=sys-auth/polkit-0.97
	net-print/cups
"
RDEPEND="${DEPEND}
	sys-apps/dbus
"
BDEPEND="
	>=dev-util/gdbus-codegen-2.30.0
	>=dev-util/intltool-0.40.6
	virtual/pkgconfig
	sys-devel/gettext
"

src_prepare() {
	default

	# Regenerate dbus-codegen files to fix build with glib-2.30.x; bug #410773
	rm -v src/cph-iface-mechanism.{c,h} || die
}
