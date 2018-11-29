# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit font

DESCRIPTION="Google's font family that aims to support all the world's languages (plus Arimo, Cousine & Tinos)"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlei18n/noto-fonts"

COMMIT="d7af81e614086435102cca95961b141b3530a027"
SRC_URI="https://github.com/googlei18n/noto-fonts/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="*"

IUSE="cjk emoji extra minimal"

RESTRICT="binchecks strip"

RDEPEND="
	>=media-fonts/croscorefonts-${PV}

	media-fonts/crosextrafonts-caladea
	media-fonts/crosextrafonts-carlito

	cjk? ( media-fonts/noto-cjk )
	emoji? ( media-fonts/noto-emoji )
"

S="${WORKDIR}/${PN}-fonts-${COMMIT}"

FONT_SUFFIX="ttf"
FONT_CONF=(
	# From Gentoo
	"${FILESDIR}"/62-croscore-arimo.conf
	"${FILESDIR}"/62-croscore-cousine.conf
	"${FILESDIR}"/62-croscore-tinos.conf
	# From ArchLinux
	"${FILESDIR}"/66-noto-serif.conf
	"${FILESDIR}"/66-noto-mono.conf
	"${FILESDIR}"/66-noto-sans.conf
)

# Noto upstream offers both hinted and unhinted versions of their fonts.
# Based on their homepage, the hinted version is the default recommendation.
#
# 	https://www.google.com/get/noto/
#
# Also based on their homepage (and GitHub repository) the extra font variants include:
#
# 	Condensed
# 	Extra
# 	SemiBold
#
# And the minimal set of fonts include:
#
# 	Noto Sans
# 	Noto Serif
# 	Noto Sans Display
# 	Noto Serif Display
# 	Noto Mono
# 	Noto Color Emoji
# 	Noto Emoji
# 	Noto Music
#
# In addition, they also maintain the Arimo, Cousine & Tinos font sets:
#
# 	https://github.com/googlei18n/noto-fonts/pull/400
src_install() {
	if ! use extra; then
		rm "${S}"/{hinted,unhinted}/Noto*Condensed*.ttf || die
		rm "${S}"/{hinted,unhinted}/Noto*Extra*.ttf || die
		rm "${S}"/{hinted,unhinted}/Noto*SemiBold*.ttf || die
	fi

	if use minimal; then
		mv "${S}"/hinted/ "${S}"/hinted.old || die
		mkdir "${S}"/hinted/ || die

		cp "${S}"/hinted.old/Arimo* "${S}"/hinted/ || die
		cp "${S}"/hinted.old/Cousine* "${S}"/hinted/ || die
		cp "${S}"/hinted.old/NotoMusic* "${S}"/hinted/ || die
		cp "${S}"/hinted.old/NotoSansDisplay-* "${S}"/hinted/ || die
		cp "${S}"/hinted.old/NotoSansMono-* "${S}"/hinted/ || die
		cp "${S}"/hinted.old/NotoSans-* "${S}"/hinted/ || die
		cp "${S}"/hinted.old/NotoSerifDisplay-* "${S}"/hinted/ || die
		cp "${S}"/hinted.old/NotoSerif-* "${S}"/hinted/ || die
		cp "${S}"/hinted.old/Tinos* "${S}"/hinted/ || die
	else
		FONT_S="${S}"/unhinted/ font_src_install
	fi

	FONT_S="${S}"/hinted/ font_src_install
}
