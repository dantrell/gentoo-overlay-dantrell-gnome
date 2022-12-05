# Distributed under the terms of the GNU General Public License v2

EAPI="8"

GNOME_ORG_MODULE="NetworkManager-${PN##*-}"

inherit gnome2

DESCRIPTION="NetworkManager OpenVPN plugin"
HOMEPAGE="https://gitlab.gnome.org/GNOME/NetworkManager-openvpn"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk gtk4 +legacy test"

RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/glib-2.34:2
	dev-libs/libxml2:2
	>=net-misc/networkmanager-1.7.0:=
	>=net-vpn/openvpn-2.1
	gtk? (
		>=app-crypt/libsecret-0.18
		legacy? ( >=gnome-extra/nm-applet-1.7.0[gtk] )
		!legacy? ( >=net-libs/libnma-1.7.0 )
		>=x11-libs/gtk+-3.4:3
	)
	gtk4? (
		>=gui-libs/gtk-4.0:4
	)
"
RDEPEND="
	${DEPEND}
	acct-group/nm-openvpn
	acct-user/nm-openvpn
"
BDEPEND="
	sys-devel/gettext
	>=dev-util/intltool-0.35
	virtual/pkgconfig
"

src_prepare() {
	if has_version '<dev-libs/glib-2.44.0'; then
		eapply "${FILESDIR}"/${PN}-1.10.2-support-glib-2.42.patch
	fi

	gnome2_src_prepare
}

src_configure() {
	# --localstatedir=/var needed per bug #536248
	gnome2_src_configure \
		--localstatedir=/var \
		--disable-more-warnings \
		--disable-static \
		--with-dist-version=Gentoo \
		$(use_with gtk gnome) \
		$(use_with gtk4) \
		$(use_with legacy libnm-glib)
}
