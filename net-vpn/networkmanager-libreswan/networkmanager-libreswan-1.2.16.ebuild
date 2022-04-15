# Distributed under the terms of the GNU General Public License v2

EAPI="8"

GNOME_ORG_MODULE="NetworkManager-libreswan"

inherit gnome2

DESCRIPTION="NetworkManager libreswan plugin"
HOMEPAGE="https://wiki.gnome.org/Projects/NetworkManager/VPN"
SRC_URI="https://download.gnome.org/sources/${GNOME_ORG_MODULE}/1.2/${GNOME_ORG_MODULE}-${PV}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE="gtk gtk4 +legacy"

RDEPEND="
	>=dev-libs/glib-2.36:2
	>=dev-libs/libnl-3.2.8:3
	>=net-misc/networkmanager-1.2.0:=
	net-vpn/libreswan
	gtk? (
		app-crypt/libsecret
		legacy? ( >=gnome-extra/nm-applet-1.2.0[gtk] )
		!legacy? ( >=gnome-extra/nm-applet-1.2.0 )
		>=x11-libs/gtk+-3.4:3
	)
	gtk4? (
		>=gui-libs/gtk-4.0:4
	)
	!net-vpn/networkmanager-openswan
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/gettext
	dev-util/intltool
	virtual/pkgconfig
"

src_configure() {
	local myconf=(
		--disable-more-warnings
		--disable-static
		--with-dist-version=Gentoo
		--without-libnm-glib
		$(use_with gtk gnome)
		$(use_with gtk4)
	)
	gnome2_src_configure "${myconf[@]}"
}
