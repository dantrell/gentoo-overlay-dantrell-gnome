# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools

EGIT_COMMIT="0e1124df9e97129c5e0d9996a2c3876ae18f01c4"
MY_PN="${PN/network/network-}"

DESCRIPTION="NetworkManager WireGuard plugin"
HOMEPAGE="https://github.com/max-moser/network-manager-wireguard"
SRC_URI="https://github.com/max-moser/${MY_PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+gtk +legacy +nls"

RDEPEND="
	>=net-misc/networkmanager-1.7.0:=[resolvconf]
	net-vpn/wireguard-tools[wg-quick]
	>=dev-libs/glib-2.32:2
	gtk? (
		>=x11-libs/gtk+-3.4:3
		legacy? (
			gnome-extra/nm-applet[gtk]
			<net-misc/networkmanager-1.19:=
		)
		!legacy? ( >=net-libs/libnma-1.7.0 )
		>=app-crypt/libsecret-0.18
	)
"

DEPEND="${RDEPEND}"

BDEPEND="
	virtual/pkgconfig
	nls? (
		dev-util/intltool
		sys-devel/gettext
	)
"

S="${WORKDIR}/${MY_PN}-${EGIT_COMMIT}"

PATCHES=(
	"${FILESDIR}"/${PN}-0_pre20191128-change-appdata-path.patch
)

src_prepare() {
	default

	if has_version '<dev-libs/glib-2.44.0'; then
		eapply "${FILESDIR}"/${PN}-0_pre20191128-support-glib-2.42.patch
	fi

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-lto
		--disable-more-warnings
		--disable-static
		$(use_with gtk gnome)
		$(use_with legacy libnm-glib)
		$(use_enable nls)
		--with-dist-version="Gentoo"
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	find "${ED}" -type f -name "*.la" -delete || die
}
