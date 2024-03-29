# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="A library to discover and manipulate DLNA renderers"
HOMEPAGE="https://01.org/dleyna/"
SRC_URI="https://01.org/sites/default/files/downloads/dleyna/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE=""

DEPEND="
	>=dev-libs/glib-2.28:2
	>=media-libs/gupnp-dlna-0.9.4:2.0
	>=net-libs/dleyna-core-0.5
	>=net-libs/gssdp-0.13.2:0/3
	>=net-libs/gupnp-0.20.5:0/4
	>=net-libs/gupnp-av-0.11.5
	>=net-libs/libsoup-2.28.2:2.4
"
RDEPEND="${DEPEND}
	net-libs/dleyna-connector-dbus
"
BDEPEND="
	virtual/pkgconfig
"

src_install() {
	default
	find "${ED}" -name "*.la" -delete || die
}
