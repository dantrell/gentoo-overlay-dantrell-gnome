# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DESCRIPTION="Spellchecker wrapping library"
HOMEPAGE="https://abiword.github.io/enchant/"
SRC_URI="https://github.com/AbiWord/enchant/releases/download/v${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="2/3"
KEYWORDS="~*"

IUSE="aspell +hunspell nuspell test voikko"
REQUIRED_USE="|| ( aspell hunspell nuspell )"

RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.6:2
	aspell? ( app-text/aspell )
	hunspell? ( >=app-text/hunspell-1.2.1:0= )
	nuspell? ( >=app-text/nuspell-5.1.0:0= )
	voikko? ( dev-libs/libvoikko )
"
RDEPEND="${COMMON_DEPEND}
	!<app-text/enchant-1.6.1-r2:0
"
DEPEND="${COMMON_DEPEND}
	test? ( >=dev-libs/unittest++-2.0.0-r2 )
"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-2.3.3-include-cstring.patch
)

src_configure() {
	local myconf=(
		--datadir="${EPREFIX}"/usr/share/enchant
		--disable-static
		$(use_enable test relocatable)
		$(use_with aspell)
		$(use_with hunspell)
		$(use_with nuspell)
		$(use_with voikko)
		--without-hspell
		--without-applespell
		--without-zemberek
		--with-hunspell-dir="${EPREFIX}"/usr/share/hunspell/
	)
	econf "${myconf[@]}"
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
