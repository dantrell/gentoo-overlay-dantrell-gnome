# Distributed under the terms of the GNU General Public License v2

EAPI="5"

MY_PN="${PN/s/S}"

inherit font

DESCRIPTION="Unicode font for Latin, IPA Extensions, Greek, Cyrillic and many Symbol Blocks"
HOMEPAGE="https://web.archive.org/web/20170811162601/http://users.teilar.gr/~g1951d/"
SRC_URI="mirror://mirthil/${PN}/${P}.zip"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="*"

IUSE="doc"

RESTRICT="mirror bindist"

DEPEND="app-arch/unzip"
RDEPEND=""

S="${WORKDIR}"
FONT_S="${S}"
FONT_SUFFIX="ttf"

src_prepare() {
	if use doc; then
		DOCS="${MY_PN}.pdf"
	fi
}
