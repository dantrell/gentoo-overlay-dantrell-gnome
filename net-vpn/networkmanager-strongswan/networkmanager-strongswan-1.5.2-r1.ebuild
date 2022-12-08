# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit autotools

MY_PN="NetworkManager"
MY_P="${P/networkmanager/"${MY_PN}"}"

DESCRIPTION="NetworkManager StrongSwan plugin"
HOMEPAGE="https://www.strongswan.org/"
SRC_URI="https://download.strongswan.org/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+legacy"

RDEPEND="
	app-crypt/libsecret
	legacy? ( gnome-extra/nm-applet[gtk] )
	!legacy? ( >=net-libs/libnma-1.1.0 )
	net-misc/networkmanager:=[resolvconf]
	>=net-vpn/strongswan-5.8.3[networkmanager]
	x11-libs/gtk+:3
"

DEPEND="${RDEPEND}"

BDEPEND="
	dev-util/intltool
	virtual/pkgconfig
"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		# Don't enable all warnings, as some are treated as errors and the compilation will fail
		--disable-more-warnings
		--disable-static
		$(use_with legacy libnm-glib)
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	find "${D}" -name '*.la' -delete || die
}
