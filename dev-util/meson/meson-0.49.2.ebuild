# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_6,3_7,3_8,3_9} )

inherit distutils-r1 toolchain-funcs

DESCRIPTION="Open source build system"
HOMEPAGE="https://mesonbuild.com/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	test? (
		dev-libs/glib:2
		dev-libs/gobject-introspection:=
		dev-util/ninja
		dev-vcs/git
		virtual/pkgconfig
	)
"

PATCHES=(
	"${FILESDIR}"/meson-0.49-python3.5-tests.patch
)

python_prepare_all() {
	# ASAN and sandbox both want control over LD_PRELOAD
	# https://bugs.gentoo.org/673016
	sed -i -e 's/test_generate_gir_with_address_sanitizer/_&/' run_unittests.py || die

	distutils-r1_python_prepare_all
}

src_test() {
	tc-export PKG_CONFIG
	if ${PKG_CONFIG} --exists Qt5Core && ! ${PKG_CONFIG} --exists Qt5Gui; then
		ewarn "Found Qt5Core but not Qt5Gui; skipping tests"
	else
		distutils-r1_src_test
	fi
}

python_test() {
	(
		# test_meson_installed
		unset PYTHONDONTWRITEBYTECODE

		# test_cross_file_system_paths
		unset XDG_DATA_HOME

		${EPYTHON} -u run_tests.py
	) || die "Testing failed with ${EPYTHON}"
}

python_install_all() {
	distutils-r1_python_install_all

	insinto /usr/share/vim/vimfiles
	doins -r data/syntax-highlighting/vim/{ftdetect,indent,syntax}
	insinto /usr/share/zsh/site-functions
	doins data/shell-completions/zsh/_meson
}
