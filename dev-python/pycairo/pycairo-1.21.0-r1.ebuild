# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} pypy3 )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1

DESCRIPTION="Python bindings for the cairo library"
HOMEPAGE="
	https://www.cairographics.org/pycairo/
	https://github.com/pygobject/pycairo/
	https://pypi.org/project/pycairo/
"
SRC_URI="
	https://github.com/pygobject/${PN}/releases/download/v${PV}/${P}.tar.gz
"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="*"

IUSE="examples"

BDEPEND="
	test? (
		dev-python/hypothesis[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
	)
"
RDEPEND="
	>=x11-libs/cairo-1.13.1[svg(+)]
"
DEPEND="${RDEPEND}"

distutils_enable_sphinx docs \
	dev-python/sphinx-rtd-theme
distutils_enable_tests setup.py

python_install() {
	distutils-r1_python_install \
		install_pkgconfig --pkgconfigdir="${EPREFIX}/usr/$(get_libdir)/pkgconfig"
}

python_install_all() {
	if use examples; then
		dodoc -r examples
	fi

	distutils-r1_python_install_all
}
