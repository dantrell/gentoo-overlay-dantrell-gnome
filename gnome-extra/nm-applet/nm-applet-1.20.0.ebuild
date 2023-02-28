# Distributed under the terms of the GNU General Public License v2

EAPI="8"
GNOME_ORG_MODULE="network-manager-applet"

inherit gnome.org meson xdg

DESCRIPTION="NetworkManager connection editor and applet"
HOMEPAGE="https://wiki.gnome.org/Projects/NetworkManager"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="appindicator modemmanager selinux teamd"

RDEPEND="
	>=dev-libs/glib-2.38:2
	>=app-crypt/libsecret-0.18
	>=net-libs/libnma-1.8.27
	>=x11-libs/gtk+-3.10:3
	>=dev-libs/libgudev-147:=
	>=x11-libs/libnotify-0.7.0
	>=net-misc/networkmanager-1.16:=[modemmanager?,teamd?]
	appindicator? (
		dev-libs/libayatana-appindicator
		>=dev-libs/libdbusmenu-16.04.0
	)
	modemmanager? ( net-misc/modemmanager )
	selinux? ( sys-libs/libselinux )
	teamd? ( >=dev-libs/jansson-2.7:= )

	virtual/freedesktop-icon-theme
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/libxml2
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	# From Gentoo:
	# 	https://bugs.gentoo.org/831829
	"${FILESDIR}"/${PN}-1.24.0-meson-0.61.patch
)

src_configure() {
	local emesonargs=(
		-Dappindicator=$(usex appindicator ayatana no)
		$(meson_use modemmanager wwan)
		$(meson_use selinux)
		$(meson_use teamd team)
		-Dmore_asserts=0
		-Dld_gc=false
	)
	meson_src_configure
}
