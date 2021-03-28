# Distributed under the terms of the GNU General Public License v2

EAPI="7"

MY_PN="${PN/s/S}"

inherit font

DESCRIPTION="Unicode font for Latin, IPA Extensions, Greek, Cyrillic and many Symbol Blocks"
HOMEPAGE="https://web.archive.org/web/20180212144935/http://users.teilar.gr:80/~g1951d"
SRC_URI="mirror://mirthil/${PN}/${P}.zip"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~*"

IUSE="doc"

RESTRICT="mirror bindist"

BDEPEND="app-arch/unzip"

S="${WORKDIR}"
FONT_S="${S}"
FONT_SUFFIX="ttf"

src_prepare() {
	default
	if use doc; then
		DOCS="${MY_PN}.pdf"
	fi
	mv "${S}"/hinted"${MY_PN}".ttf "${S}"/"${MY_PN}"_hint.ttf || die
}
