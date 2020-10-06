# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME_ORG_MODULE="NetworkManager-${PN##*-}"
GNOME2_LA_PUNT="yes"
GNOME2_EAUTORECONF="yes"

inherit gnome2

DESCRIPTION="NetworkManager Fortinet SSLVPN compatible plugin"
HOMEPAGE="https://wiki.gnome.org/Projects/NetworkManager"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk +legacy"

RDEPEND="
	>=net-misc/networkmanager-1.2:=
	>=dev-libs/glib-2.32:2
	net-dialup/ppp:=
	>=net-vpn/openfortivpn-1.2.0
	gtk? (
		>=app-crypt/libsecret-0.18
		legacy? ( >=gnome-extra/nm-applet-1.2.0[gtk] )
		!legacy? ( >=net-libs/libnma-1.2.0 )
		>=x11-libs/gtk+-3.4:3
	)
"
DEPEND="${RDEPEND}
	dev-util/gdbus-codegen
	>=sys-devel/gettext-0.19
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--with-dist-version=Gentoo \
		--localstatedir=/var \
		$(use_with gtk gnome) \
		$(use_with legacy libnm-glib)
}
