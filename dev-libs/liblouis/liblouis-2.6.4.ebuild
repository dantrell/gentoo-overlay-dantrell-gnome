# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python{2_7,3_3,3_4} )
PYTHON_REQ_USE="wide-unicode(+)"
DISTUTILS_OPTIONAL=1

inherit distutils-r1

DESCRIPTION="An open-source braille translator, back-translator and formatter"
HOMEPAGE="http://www.liblouis.org/ https://github.com/liblouis/liblouis"
SRC_URI="https://github.com/liblouis/liblouis/releases/download/v${PV}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="*"

IUSE="python"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="python? ( ${PYTHON_DEPS} )"
DEPEND="${RDEPEND}"

src_prepare() {
	default

	if use python; then
		distutils-r1_src_prepare
	fi
}

src_configure() {
	econf --enable-ucs4
}

python_compile() {
	default

	if use python; then
		LD_LIBRARY_PATH="${S}/liblouis/.libs" distutils-r1_src_compile
	fi
}

python_install() {
	DOCS="AUTHORS ChangeLog NEWS README" default
	dohtml doc/liblouis.html

	if use python; then
		LD_LIBRARY_PATH="${S}/liblouis/.libs" distutils-r1_src_install
	fi
}

pkg_postinst() {
	if use python; then
		distutils-r1_pkg_postinst
	fi
}

pkg_postrm() {
	if use python; then
		distutils-r1_pkg_postrm
	fi
}
