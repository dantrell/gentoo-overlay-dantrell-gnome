# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python{3_8,3_9,3_10} )

inherit distutils-r1 toolchain-funcs

DESCRIPTION="Open source build system"
HOMEPAGE="https://mesonbuild.com/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~*"

IUSE="test"

RESTRICT="!test? ( test )"

DEPEND="
	test? (
		dev-libs/glib:2
		dev-libs/gobject-introspection:=
		dev-util/ninja
		dev-vcs/git
		sys-libs/zlib[static-libs(+)]
		virtual/pkgconfig
	)
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.58.2-mcompile-treat-load-average-as-a-float.patch
)

python_prepare_all() {
	local disable_unittests=(
		# ASAN and sandbox both want control over LD_PRELOAD
		# https://bugs.gentoo.org/673016
		-e 's/test_generate_gir_with_address_sanitizer/_&/'

		# ASAN is unsupported on some targets
		# https://bugs.gentoo.org/692822
		-e 's/test_pch_with_address_sanitizer/_&/'

		# https://github.com/mesonbuild/meson/issues/7203
		-e 's/test_templates/_&/'

		# Broken due to python2 wrapper
		-e 's/test_python_module/_&/'
	)

	sed -i "${disable_unittests[@]}" run_unittests.py || die

	# Broken due to python2 script created by python_wrapper_setup
	rm -r "test cases/frameworks/1 boost" || die

	distutils-r1_python_prepare_all
}

src_test() {
	tc-export PKG_CONFIG
	if ${PKG_CONFIG} --exists Qt5Core && ! ${PKG_CONFIG} --exists Qt5Gui; then
		ewarn "Found Qt5Core but not Qt5Gui; skipping tests"
	else
		# https://bugs.gentoo.org/687792
		unset PKG_CONFIG
		distutils-r1_src_test
	fi
}

python_test() {
	(
		# test_meson_installed
		unset PYTHONDONTWRITEBYTECODE

		# test_cross_file_system_paths
		unset XDG_DATA_HOME

		# 'test cases/unit/73 summary' expects 80 columns
		export COLUMNS=80

		# If JAVA_HOME is not set, meson looks for javac in PATH.
		# If javac is in /usr/bin, meson assumes /usr/include is a valid
		# JDK include path. Setting JAVA_HOME works around this broken
		# autodection. If no JDK is installed, we should end up with an empty
		# value in JAVA_HOME, and the tests should get skipped.
		export JAVA_HOME=$(java-config -O 2>/dev/null)

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