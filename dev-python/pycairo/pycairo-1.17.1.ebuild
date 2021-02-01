# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{2_7,3_7,3_8,3_9} pypy{,3} )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1

DESCRIPTION="Python bindings for the cairo library"
HOMEPAGE="https://www.cairographics.org/pycairo/ https://github.com/pygobject/pycairo"
SRC_URI="https://github.com/pygobject/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="*"

IUSE="doc examples test"

RESTRICT="!test? ( test )"

BDEPEND="
	doc? ( dev-python/sphinx )
	test? (
		dev-python/hypothesis[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
	)
"
RDEPEND="
	>=x11-libs/cairo-1.13.1[svg]
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/pycairo-1.17.0-pkgconfigdir.patch
)

python_compile_all() {
	if use doc; then
		emake -C docs
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
	use doc && local HTML_DOCS=( docs/_build/. )

	if use examples; then
		dodoc -r examples
	fi

	distutils-r1_python_install_all
}
