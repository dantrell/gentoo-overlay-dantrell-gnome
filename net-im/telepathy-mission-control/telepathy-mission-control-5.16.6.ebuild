# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_REQ_USE="xml(+)"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit autotools gnome2 python-any-r1

DESCRIPTION="An account manager and channel dispatcher for the Telepathy framework"
HOMEPAGE="https://gitlab.freedesktop.org/telepathy/telepathy-mission-control"
SRC_URI="https://telepathy.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="ck debug elogind networkmanager systemd"
REQUIRED_USE="
	?? ( ck elogind systemd )
"

# Tests are broken, see upstream bug #29334 and #64212
# upstream doesn't want it enabled everywhere (#29334#c12)
RESTRICT="test"

RDEPEND="
	>=dev-libs/dbus-glib-0.82
	>=dev-libs/glib-2.32:2
	>=sys-apps/dbus-0.95
	>=sys-power/upower-0.99:=
	>=net-libs/telepathy-glib-0.20
	networkmanager? ( >=net-misc/networkmanager-1:= )

	ck? ( >=sys-power/upower-0.99:=[ck] )
	elogind? ( sys-auth/elogind )
	systemd? ( >=sys-apps/systemd-186:0= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-libs/libxslt
	>=dev-build/gtk-doc-am-1.17
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
		$(use_enable ck deprecated) \
		$(use_enable debug) \
		$(use_with networkmanager connectivity nm)
}
