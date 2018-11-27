# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6,3_7} pypy{,3} )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1

DESCRIPTION="Python bindings for the cairo library"
HOMEPAGE="https://www.cairographics.org/pycairo/ https://github.com/pygobject/pycairo"
SRC_URI="https://github.com/pygobject/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~*"

IUSE="doc examples test"

RDEPEND="
	>=x11-libs/cairo-1.13.1[svg]
"
DEPEND="${RDEPEND}
	doc? ( dev-python/sphinx )
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/hypothesis[${PYTHON_USEDEP}]
	)
"

PATCHES=(
	"${FILESDIR}"/pycairo-1.17.0-pkgconfigdir.patch
)

python_compile_all() {
	use doc && emake -C docs
}

python_test() {
	esetup.py test
}

python_install() {
	distutils-r1_python_install \
		install_pkgconfig --pkgconfigdir="${EPREFIX}/usr/$(get_libdir)/pkgconfig"
}

python_install_all() {

	use doc && local HTML_DOCS=( docs/_build/. )
	if use examples; then
		dodoc -r examples
	fi

	distutils-r1_python_install_all
}
