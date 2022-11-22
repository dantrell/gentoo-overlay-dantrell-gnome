# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit meson

DESCRIPTION="Linux D-Bus Message Broker"
HOMEPAGE="https://github.com/bus1/dbus-broker/wiki"
SRC_URI="https://github.com/bus1/${PN}/releases/download/v${PV}/${P}.tar.xz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~*"

IUSE="apparmor audit doc elogind +launcher selinux systemd"
REQUIRED_USE="
	^^ ( elogind systemd )
"

DEPEND="
	apparmor? (
		>=sys-libs/libapparmor-3.0
	)
	audit? (
		>=sys-process/audit-3.0
		>=sys-libs/libcap-ng-0.6
	)
	launcher? (
		>=dev-libs/expat-2.2
		elogind? ( >=sys-auth/elogind-230:0= )
		systemd? ( >=sys-apps/systemd-230:0= )
	)
	selinux? ( >=sys-libs/libselinux-3.2 )
"
RDEPEND="${DEPEND}
	launcher? ( sys-apps/dbus )"
BDEPEND="
	doc? ( dev-python/docutils )
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-32-apparmor-libaudit.patch"
)

src_prepare() {
	# From GNOME Without Systemd:
	# 	https://forums.gentoo.org/viewtopic-p-8267112.html#8267112
	eapply "${FILESDIR}"/${PN}-22-support-elogind.patch
}

src_configure() {
	local emesonargs=(
		$(meson_use apparmor)
		$(meson_use audit)
		$(meson_use doc docs)
		$(meson_use elogind)
		$(meson_use launcher)
		$(meson_use selinux)
	)
	meson_src_configure
}
