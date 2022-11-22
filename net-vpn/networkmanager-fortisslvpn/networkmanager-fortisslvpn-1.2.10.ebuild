# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME_ORG_MODULE="NetworkManager-${PN##*-}"
GNOME2_LA_PUNT="yes"

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
	gtk? (
		>=app-crypt/libsecret-0.18
		legacy? ( >=gnome-extra/nm-applet-1.2.0[gtk] )
		!legacy? ( >=net-libs/libnma-1.2.0 )
		>=x11-libs/gtk+-3.4:3
	)
"
DEPEND="${RDEPEND}
	net-dialup/ppp:=
	>=net-vpn/openfortivpn-1.2.0
"
BDEPEND="
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

src_install() {
	gnome2_src_install

	# From AppStream (the /usr/share/appdata location is deprecated):
	# 	https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html#spec-component-location
	# 	https://bugs.gentoo.org/709450
	mv "${ED}"/usr/share/{appdata,metainfo} || die

	find "${ED}" -type f -name "*.la" -delete || die
}
