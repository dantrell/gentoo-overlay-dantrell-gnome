# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="utility library for higher level dLeyna libraries"
HOMEPAGE="https://01.org/dleyna/"
SRC_URI="https://01.org/sites/default/files/downloads/dleyna/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="1.0/4"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.28:2
	>=net-libs/gupnp-0.20.5:0/4
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
"

src_install() {
	default
	find "${ED}" -name "*.la" -delete || die
}
