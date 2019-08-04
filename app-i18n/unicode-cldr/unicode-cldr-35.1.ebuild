# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Unicode Common Locale Data Repository"
HOMEPAGE="http://cldr.unicode.org/"
if [[ "${PV}" =~ ^[[:digit:]]+\.0$ ]]; then
	SRC_URI="https://unicode.org/Public/${PN#*-}/${PV%.0}/${PN#*-}-common-${PV}.zip -> ${PN}-common-${PV}.zip"
else
	SRC_URI="https://unicode.org/Public/${PN#*-}/${PV}/${PN#*-}-common-${PV}.zip -> ${PN}-common-${PV}.zip"
fi

LICENSE="unicode"
SLOT="0"
KEYWORDS="~*"

IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=""

S="${WORKDIR}"

src_install() {
	insinto /usr/share/unicode/cldr
	doins -r common
}
