# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit eutils python-single-r1

DESCRIPTION="Korean Hangul engine for IBus"
HOMEPAGE="https://github.com/libhangul/ibus-hangul/wiki"
SRC_URI="https://github.com/libhangul/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="+nls"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	>=app-i18n/ibus-1.4[python,${PYTHON_USEDEP}]
	>=app-i18n/libhangul-0.1
	=dev-python/pygobject-2*[${PYTHON_USEDEP}]
	=dev-python/pygtk-2*[${PYTHON_USEDEP}]
	nls? ( virtual/libintl )
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
	nls? (
		dev-util/intltool
		>=sys-devel/gettext-0.17
	)
"

DOCS="AUTHORS ChangeLog NEWS README"

src_prepare() {
	sed -ie "s:python:${EPYTHON}:" \
		setup/ibus-setup-hangul.in || die

	# From ibus-hangul:
	# 	https://github.com/choehwanjin/ibus-hangul/commit/99d67447737be2d0b08fefc4d9fba588621fe8fb
	# 	https://github.com/choehwanjin/ibus-hangul/commit/8cffcc0b0141d5dc43d96f26a5e7244dfbe1a556
	# 	https://github.com/choehwanjin/ibus-hangul/commit/4e4e03897bc90af230ee2051deda44da5804fef7
	# 	https://github.com/choehwanjin/ibus-hangul/commit/374a83bc13b5d159134ee6a3b7e3d71190e05ffe
	epatch "${FILESDIR}"/${PN}-1.5.0-allow-hangul-mode-to-be-toggled.patch
	epatch "${FILESDIR}"/${PN}-1.5.0-add-hangul-toggle-key-setup.patch
	epatch "${FILESDIR}"/${PN}-1.5.0-update-hangul-mode-property-on-toggle-key.patch
	epatch "${FILESDIR}"/${PN}-1.5.0-change-property-label-hangul-lock-hangul-mode.patch
}

src_configure() {
	econf $(use_enable nls)
}
