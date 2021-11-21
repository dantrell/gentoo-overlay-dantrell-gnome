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
	insinto /usr/share/unicode/emoji
	local source_file target_file
	for source_file in ${A}; do
		target_file="${source_file#${PN%-*}-}"
		target_file="${target_file%-${PV}.txt}.txt"
		newins "${DISTDIR}/${source_file}" "${target_file}"
	done
}
