# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Filtering proxy for D-Bus connections"
HOMEPAGE="https://github.com/flatpak/xdg-dbus-proxy"
SRC_URI="https://github.com/flatpak/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.40:2
"
DEPEND="${RDEPEND}
	test? ( sys-apps/dbus )
"
BDEPEND="
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	virtual/pkgconfig
"

src_configure() {
	econf --enable-man
}
