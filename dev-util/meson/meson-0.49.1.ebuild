# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_5,3_6,3_7} )

inherit distutils-r1 toolchain-funcs

DESCRIPTION="Open source build system"
HOMEPAGE="http://mesonbuild.com/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~*"

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

python_prepare_all() {
	# ASAN and sandbox both want control over LD_PRELOAD
	# https://bugs.gentoo.org/673016
	sed -i -e 's/test_generate_gir_with_address_sanitizer/_&/' run_unittests.py || die

	distutils-r1_python_prepare_all
}

src_test() {
	if tc-is-gcc; then
		# LTO fails for static libs because the bfd plugin in missing.
		# Remove this workaround after sys-devel/gcc-config-2.0 is stable.
		# https://bugs.gentoo.org/672706
		tc-getPROG AR gcc-ar >/dev/null
	fi
	distutils-r1_src_test
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
