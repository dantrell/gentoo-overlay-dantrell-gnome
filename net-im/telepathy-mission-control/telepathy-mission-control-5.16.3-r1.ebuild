# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python2_7 )

inherit autotools eutils gnome2 python-any-r1

DESCRIPTION="An account manager and channel dispatcher for the Telepathy framework"
HOMEPAGE="http://cgit.freedesktop.org/telepathy/telepathy-mission-control/"
SRC_URI="http://telepathy.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"
IUSE="debug +deprecated networkmanager systemd"

RDEPEND="
	>=dev-libs/dbus-glib-0.82
	>=dev-libs/glib-2.32:2
	>=sys-apps/dbus-0.95
	>=net-libs/telepathy-glib-0.20
	networkmanager? ( >=net-misc/networkmanager-0.7 )

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

RESTRICT="test"

src_prepare() {
	# From freedesktop:
	# 	http://cgit.freedesktop.org/telepathy/telepathy-mission-control/commit/?id=3d3a13c561e858853af5c601373be3ea0746f58c
	epatch "${FILESDIR}"/${P}-server-exit-early-if-we-failed-to-create-mcdservice.patch

	if use deprecated; then
		# From Funtoo:
		# 	https://bugs.funtoo.org/browse/FL-1329
		epatch "${FILESDIR}"/${P}-restore-deprecated-code.patch
	fi

	epatch_user

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
