# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_DEPEND="2:2.5"

inherit eutils python

DESCRIPTION="The Hangul engine for IBus input platform"
HOMEPAGE="https://github.com/ibus/ibus/wiki"
SRC_URI="https://github.com/choehwanjin/ibus-hangul/releases/download/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="+nls"

RDEPEND="
	>=app-i18n/ibus-1.4
	>=app-i18n/libhangul-0.1
	=dev-python/pygobject-2*
	=dev-python/pygtk-2*
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

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	python_clean_py-compile_files
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

pkg_postinst() {
	python_mod_optimize /usr/share/${PN}
}

pkg_postrm() {
	python_mod_cleanup /usr/share/${PN}
}
