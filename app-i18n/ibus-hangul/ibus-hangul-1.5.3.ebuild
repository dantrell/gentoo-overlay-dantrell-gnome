# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_9,3_10,3_11} )

inherit gnome2-utils python-single-r1

DESCRIPTION="Korean Hangul engine for IBus"
HOMEPAGE="https://github.com/libhangul/ibus-hangul/wiki"
SRC_URI="https://github.com/libhangul/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="nls"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep '
		app-i18n/ibus[python(+),${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
	>=app-i18n/libhangul-0.1
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

src_configure() {
	econf \
		$(use_enable nls) \
		--with-python=${EPYTHON}
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
