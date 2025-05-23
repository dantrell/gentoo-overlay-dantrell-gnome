# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit multilib-minimal python-any-r1

DESCRIPTION="Mock hardware devices for creating unit tests"
HOMEPAGE="https://github.com/martinpitt/umockdev/"
SRC_URI="https://github.com/martinpitt/umockdev/releases/download/${PV}/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection static-libs test"

RESTRICT="!test? ( test )"

RDEPEND="
	virtual/libudev:=[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.32:2[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-1.32:= )
"
DEPEND="${RDEPEND}
	test? (
		${PYTHON_DEPS}
	)
	app-arch/xz-utils
	dev-libs/libgudev[${MULTILIB_USEDEP}]
	>=dev-build/gtk-doc-am-1.14
	virtual/pkgconfig
"

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

multilib_src_configure() {
	local ECONF_SOURCE="${S}"
	econf \
		--disable-gtk-doc \
		$(multilib_native_use_enable introspection) \
		$(use_enable static-libs static) \
		VALAC="$(type -P true)"
}

multilib_src_install_all() {
	einstalldocs
	find "${D}" -name '*.la' -delete || die
}
