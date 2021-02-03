# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit font

DESCRIPTION="Google's font family that aims to support all the world's languages (plus Arimo, Cousine & Tinos)"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlefonts/noto-fonts"

COMMIT="2b1fbc36600ccd8becb9f894922f644bff2cbc9b"
SRC_URI="https://github.com/googlefonts/noto-fonts/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~*"

IUSE="cjk emoji extra minimal +ttf"

RESTRICT="binchecks strip"

RDEPEND="
	>=media-fonts/croscorefonts-${PV}

	media-fonts/crosextrafonts-caladea
	media-fonts/crosextrafonts-carlito

	cjk? ( media-fonts/noto-cjk )
	emoji? ( media-fonts/noto-emoji )
"
DEPEND=""

S="${WORKDIR}/${PN}-fonts-${COMMIT}"

FONT_SUFFIX="ttf"
FONT_CONF=(
	# From Gentoo:
	"${FILESDIR}"/62-croscore-arimo.conf
	"${FILESDIR}"/62-croscore-cousine.conf
	"${FILESDIR}"/62-croscore-tinos.conf
	# From Arch:
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
# 	https://github.com/googlefonts/noto-fonts/pull/400
src_install() {
	if ! use ttf; then
		FONT_SUFFIX="${FONT_SUFFIX} otf"
	fi

	if ! use extra; then
		if use ttf; then
			rm "${S}"/{hinted,unhinted}/ttf/Noto*/Noto*Condensed*.ttf || die
			rm "${S}"/{hinted,unhinted}/ttf/Noto*/Noto*Extra*.ttf || die
			rm "${S}"/{hinted,unhinted}/ttf/Noto*/Noto*SemiBold*.ttf || die
		else
			rm "${S}"/unhinted/otf/Noto*/Noto*Condensed*.otf || die
			rm "${S}"/unhinted/otf/Noto*/Noto*Extra*.otf || die
			rm "${S}"/unhinted/otf/Noto*/Noto*SemiBold*.otf || die
		fi
	fi

	mkdir "${S}"/staging/ || die

	cp "${S}"/hinted/ttf/Arimo/* "${S}"/staging/ || die
	cp "${S}"/hinted/ttf/Cousine/* "${S}"/staging/ || die
	cp "${S}"/hinted/ttf/Tinos/* "${S}"/staging/ || die

	if use minimal; then
		if use ttf; then
			cp "${S}"/hinted/ttf/NotoMusic/* "${S}"/staging/ || die
			cp "${S}"/hinted/ttf/NotoSansDisplay/* "${S}"/staging/ || die
			cp "${S}"/hinted/ttf/NotoSansMono/* "${S}"/staging/ || die
			cp "${S}"/hinted/ttf/NotoSans/* "${S}"/staging/ || die
			cp "${S}"/hinted/ttf/NotoSerifDisplay/* "${S}"/staging/ || die
			cp "${S}"/hinted/ttf/NotoSerif/* "${S}"/staging/ || die

			find "${S}"/hinted/ttf/* -type f -size 0 -delete || die
		else
			cp "${S}"/unhinted/otf/NotoMusic/* "${S}"/staging/ || die
			cp "${S}"/unhinted/otf/NotoSansDisplay/* "${S}"/staging/ || die
			cp "${S}"/unhinted/otf/NotoSansMono/* "${S}"/staging/ || die
			cp "${S}"/unhinted/otf/NotoSans/* "${S}"/staging/ || die
			cp "${S}"/unhinted/otf/NotoSerifDisplay/* "${S}"/staging/ || die
			cp "${S}"/unhinted/otf/NotoSerif/* "${S}"/staging/ || die

			find "${S}"/unhinted/otf/* -type f -size 0 -delete || die
		fi
	else
		if use ttf; then
			cp "${S}"/hinted/ttf/*/*.ttf "${S}"/staging/ || die

			find "${S}"/hinted/ttf/* -type f -size 0 -delete || die
		else
			cp "${S}"/unhinted/otf/*/*.otf "${S}"/staging/ || die

			find "${S}"/unhinted/otf/* -type f -size 0 -delete || die
		fi
	fi

	FONT_S="${S}/staging/" font_src_install
}
