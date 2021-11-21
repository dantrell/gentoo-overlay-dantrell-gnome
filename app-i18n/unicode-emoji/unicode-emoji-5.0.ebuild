# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DESCRIPTION="UTS #51 Unicode Emoji"
HOMEPAGE="https://unicode.org/emoji/"
BASE_URI="https://unicode.org/Public/${PN#*-}/${PV}"
SRC_URI="${BASE_URI}/${PN#*-}-data.txt -> ${PN}-data-${PV}.txt
	${BASE_URI}/${PN#*-}-sequences.txt -> ${PN}-sequences-${PV}.txt
	${BASE_URI}/${PN#*-}-test.txt -> ${PN}-test-${PV}.txt
	${BASE_URI}/${PN#*-}-variation-sequences.txt -> ${PN}-variation-sequences-${PV}.txt
	${BASE_URI}/${PN#*-}-zwj-sequences.txt -> ${PN}-zwj-sequences-${PV}.txt"

LICENSE="unicode"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	:
}

src_install() {
	local a
	insinto /usr/share/${PN/-//}
	for a in ${A}; do
		newins "${DISTDIR}"/${a} $(echo ${a} | sed "s/${PN%-*}-\(.*\)-${PV}/\1/")
	done
}
