# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{2_7,3_10,3_11,3_12,3_13} pypy{,3} )
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

IUSE="doc examples test"

RESTRICT="!test? ( test )"

BDEPEND="
	doc? ( $(python_gen_any_dep 'dev-python/sphinx[${PYTHON_USEDEP}]') )
	test? (
		dev-python/hypothesis[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
	)
"
RDEPEND="
	>=x11-libs/cairo-1.13.1[svg(+)]
"
DEPEND="${RDEPEND}"

python_check_deps() {
	use doc || return 0
	python_has_version "dev-python/sphinx[${PYTHON_USEDEP}]"
}

python_compile_all() {
	if use doc; then
		sphinx-build docs -b html _build/html || die
	fi
}

python_test() {
	esetup.py test
}

python_install() {
	distutils-r1_python_install \
		install_pkgconfig --pkgconfigdir="${EPREFIX}/usr/$(get_libdir)/pkgconfig"
}

python_install_all() {
	use doc && local HTML_DOCS=( _build/html/. )

	if use examples; then
		dodoc -r examples
	fi

	distutils-r1_python_install_all
}
