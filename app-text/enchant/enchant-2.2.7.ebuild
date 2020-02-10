# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Spellchecker wrapping library"
HOMEPAGE="https://abiword.github.io/enchant/"
SRC_URI="https://github.com/AbiWord/enchant/releases/download/v${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="2/2"
KEYWORDS="~*"

IUSE="aspell +hunspell"
REQUIRED_USE="|| ( hunspell aspell )"

#	test? ( dev-libs/unittest++ )
RESTRICT="test"

# FIXME: depends on unittest++ but through pkgconfig which is a Debian hack, bug #629742
RDEPEND="
	>=dev-libs/glib-2.6:2
	aspell? ( app-text/aspell )
	hunspell? ( >=app-text/hunspell-1.2.1:0= )"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	econf \
		--datadir="${EPREFIX}"/usr/share/enchant-2 \
		--disable-static \
		$(use_with aspell) \
		$(use_with hunspell) \
		--without-hspell \
		--without-voikko \
		--with-hunspell-dir="${EPREFIX}"/usr/share/hunspell/
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
