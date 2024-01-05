# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12} )
DISTUTILS_USE_PEP517=setuptools

MY_P=${P/_/}

inherit bash-completion-r1 distutils-r1 toolchain-funcs

DESCRIPTION="Open source build system"
HOMEPAGE="https://mesonbuild.com/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~*"

IUSE="deprecated-builddir-file-references deprecated-positional-arguments test"

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
RDEPEND="
	virtual/pkgconfig
"

S=${WORKDIR}/${MY_P}

PATCHES=(
	"${FILESDIR}"/${PN}-1.2.1-python-path.patch
)

src_prepare() {
	default

	if use deprecated-positional-arguments; then
		# From Meson:
		# 	https://github.com/mesonbuild/meson/commit/8b573d7dc65bf20fcb0377ce4c56841496ad0c69
		eapply "${FILESDIR}"/${PN}-1.2.3-i18n-merge-file-do-not-disable-in-the-absence-of-gettext.patch

		# From Meson:
		# 	https://github.com/mesonbuild/meson/commit/2b01a14090748c4df2d174ea9832f212f5899491
		eapply "${FILESDIR}"/${PN}-1.2.3-i18n-merge-file-deprecate-positional-arguments.patch
		eapply "${FILESDIR}"/${PN}-1.2.3-i18n-itstool-join-deprecate-positional-arguments.patch
	fi

	if use deprecated-builddir-file-references; then
		# From Meson:
		# 	https://github.com/mesonbuild/meson/commit/ca40dda1467bd8dada7dc7d729c8136f13ccd579
		eapply "${FILESDIR}"/${PN}-0.63.3-interpreter-deprecate-builddir-file-references.patch
	fi
}

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

	sed -i "${disable_unittests[@]}" unittests/*.py || die

	# Broken due to python2 script created by python_wrapper_setup
	rm -r "test cases/frameworks/1 boost" || die

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

		# https://bugs.gentoo.org/687792
		unset PKG_CONFIG

		# test_cross_file_system_paths
		unset XDG_DATA_HOME

		# 'test cases/unit/73 summary' expects 80 columns
		export COLUMNS=80

		# If JAVA_HOME is not set, meson looks for javac in PATH.
		# If javac is in /usr/bin, meson assumes /usr/include is a valid
		# JDK include path. Setting JAVA_HOME works around this broken
		# autodetection. If no JDK is installed, we should end up with an empty
		# value in JAVA_HOME, and the tests should get skipped.
		export JAVA_HOME=$(java-config -O 2>/dev/null)

		# Call python3 instead of EPYTHON to satisfy test_meson_uninstalled.
		python3 run_tests.py
	) || die "Testing failed with ${EPYTHON}"
}

python_install_all() {
	distutils-r1_python_install_all

	insinto /usr/share/vim/vimfiles
	doins -r data/syntax-highlighting/vim/{ftdetect,indent,syntax}

	insinto /usr/share/zsh/site-functions
	doins data/shell-completions/zsh/_meson

	dobashcomp data/shell-completions/bash/meson
}
