# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python2_7 )

inherit autotools gnome2 python-any-r1

DESCRIPTION="An account manager and channel dispatcher for the Telepathy framework"
HOMEPAGE="https://cgit.freedesktop.org/telepathy/telepathy-mission-control/"
SRC_URI="https://telepathy.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~*"

IUSE="debug +deprecated networkmanager systemd"

RESTRICT="test"

RDEPEND="
	>=dev-libs/dbus-glib-0.82
	>=dev-libs/glib-2.32:2
	>=sys-apps/dbus-0.95
	>=net-libs/telepathy-glib-0.20
	networkmanager? ( >=net-misc/networkmanager-1:= )

	!deprecated? (
		systemd? ( >=sys-apps/systemd-186:0= )
	)
	!systemd? (
		deprecated? ( >=sys-power/upower-0.99:=[deprecated] )
	)
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.17
	virtual/pkgconfig
"

src_prepare() {
	# From Funtoo:
	# 	https://bugs.funtoo.org/browse/FL-1329
	eapply "${FILESDIR}"/${PN}-5.16.4-restore-deprecated-code.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		 --disable-static \
		$(use_enable debug) \
		$(use_enable deprecated) \
		$(use_with networkmanager connectivity nm)
}
