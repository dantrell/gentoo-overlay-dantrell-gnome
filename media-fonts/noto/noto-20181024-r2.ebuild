# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit font

DESCRIPTION="Google's font family that aims to support all the world's languages (plus Arimo, Cousine & Tinos)"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlefonts/noto-fonts"

COMMIT="d7af81e614086435102cca95961b141b3530a027"
SRC_URI="https://github.com/googlefonts/noto-fonts/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="*"

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
			rm "${S}"/{hinted,unhinted}/Noto*Condensed*.ttf || die
			rm "${S}"/{hinted,unhinted}/Noto*Extra*.ttf || die
			rm "${S}"/{hinted,unhinted}/Noto*SemiBold*.ttf || die
		else
			rm "${S}"/phaseIII_only/unhinted/otf/*/Noto*Condensed*.otf || die
			rm "${S}"/phaseIII_only/unhinted/otf/*/Noto*Extra*.otf || die
			rm "${S}"/phaseIII_only/unhinted/otf/*/Noto*SemiBold*.otf || die
		fi
	fi

	mkdir "${S}"/staging/ || die

	cp "${S}"/hinted/Arimo* "${S}"/staging/ || die
	cp "${S}"/hinted/Cousine* "${S}"/staging/ || die
	cp "${S}"/hinted/Tinos* "${S}"/staging/ || die

	if use minimal; then
		if use ttf; then
			cp "${S}"/hinted/NotoMusic* "${S}"/staging/ || die
			cp "${S}"/hinted/NotoSansDisplay-* "${S}"/staging/ || die
			cp "${S}"/hinted/NotoSansMono-* "${S}"/staging/ || die
			cp "${S}"/hinted/NotoSans-* "${S}"/staging/ || die
			cp "${S}"/hinted/NotoSerifDisplay-* "${S}"/staging/ || die
			cp "${S}"/hinted/NotoSerif-* "${S}"/staging/ || die
		else
			cp "${S}"/phaseIII_only/unhinted/otf/NotoMusic/* "${S}"/staging/ || die
			cp "${S}"/phaseIII_only/unhinted/otf/NotoSansDisplay/* "${S}"/staging/ || die
			cp "${S}"/phaseIII_only/unhinted/otf/NotoSansMono/* "${S}"/staging/ || die
			cp "${S}"/phaseIII_only/unhinted/otf/NotoSans/* "${S}"/staging/ || die
			cp "${S}"/phaseIII_only/unhinted/otf/NotoSerifDisplay/* "${S}"/staging/ || die
			cp "${S}"/phaseIII_only/unhinted/otf/NotoSerif/* "${S}"/staging/ || die
		fi

		FONT_S="${S}/staging/" font_src_install
	else
		if use ttf; then
			FONT_S="${S}/unhinted/" font_src_install
			FONT_S="${S}/hinted/" font_src_install
		else
			cp "${S}"/phaseIII_only/unhinted/otf/*/*.otf "${S}"/staging/ || die

			FONT_S="${S}/staging/" font_src_install
		fi
	fi
}
