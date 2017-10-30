# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1

DESCRIPTION="Python bindings for the cairo library"
HOMEPAGE="https://www.cairographics.org/pycairo/ https://github.com/pygobject/pycairo"
SRC_URI="https://github.com/pygobject/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="*"

IUSE="doc examples test xcb"

# Note: xpyb is used as the C header, not Python modules
RDEPEND="
	>=x11-libs/cairo-1.13.1[svg,xcb?]
"
DEPEND="${RDEPEND}
	xcb? ( $(python_gen_cond_dep '>=x11-libs/xpyb-1.3' 'python2*') )
	doc? ( dev-python/sphinx )
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/hypothesis[${PYTHON_USEDEP}]
	)
"

python_prepare_all() {
	# Fix pkgconfig path
	sed -i -e "/libdir =/s:\"lib\":\"$(get_libdir)\":" setup.py || die
	distutils-r1_python_prepare_all
}

python_compile() {
	local enable_xpyb
	python_is_python3 || enable_xpyb=$(usex xcb "--enable-xpyb" "")

	esetup.py build ${enable_xpyb}
}

python_compile_all() {
	use doc && emake -C docs
}

python_test() {
	local enable_xpyb
	python_is_python3 || enable_xpyb=$(usex xcb "--enable-xpyb" "")

	esetup.py test ${enable_xpyb}
}

python_install_all() {

	use doc && local HTML_DOCS=( docs/_build/. )
	if use examples; then
		dodoc -r examples
	fi

	distutils-r1_python_install_all
}
