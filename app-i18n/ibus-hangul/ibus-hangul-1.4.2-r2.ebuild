# Distributed under the terms of the GNU General Public License v2

EAPI="5"
PYTHON_COMPAT=( python2_7 )

inherit eutils python-single-r1

DESCRIPTION="The Hangul engine for IBus input platform"
HOMEPAGE="https://github.com/choehwanjin/${PN}"
SRC_URI="https://github.com/choehwanjin/${PN}/releases/download/${PV}/${P}.tar.gz"

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

DOCS=( AUTHORS ChangeLog NEWS README )

src_prepare() {
	sed -i -e "s/python/${EPYTHON}/" setup/ibus-setup-hangul.in || die

	epatch "${FILESDIR}"/${PN}-1.5.0-allow-hangul-mode-to-be-toggled.patch
	epatch "${FILESDIR}"/${PN}-1.5.0-add-hangul-toggle-key-setup.patch
	epatch "${FILESDIR}"/${PN}-1.5.0-update-hangul-mode-property-on-toggle-key.patch
	epatch "${FILESDIR}"/${PN}-1.5.0-change-property-label-hangul-lock-hangul-mode.patch
}

src_configure() {
	econf $(use_enable nls)
}
