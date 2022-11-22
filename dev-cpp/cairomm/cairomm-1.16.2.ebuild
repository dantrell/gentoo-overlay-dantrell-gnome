# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python{3_8,3_9,3_10,3_11} )

inherit meson-multilib python-any-r1

DESCRIPTION="C++ bindings for the Cairo vector graphics library"
HOMEPAGE="https://cairographics.org/cairomm/ https://gitlab.freedesktop.org/cairo/cairomm"
SRC_URI="https://www.cairographics.org/releases/${P}.tar.xz"

LICENSE="LGPL-2+"
SLOT="1.16"
KEYWORDS="*"

IUSE="gtk-doc test X"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/libsigc++-3.0.0:3[gtk-doc?,${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.12.0[X=,${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	test? (
		dev-libs/boost:=[${MULTILIB_USEDEP}]
		media-libs/fontconfig[${MULTILIB_USEDEP}]
	)
"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? (
		${PYTHON_DEPS}
		>=dev-cpp/mm-common-1.0.4
		app-doc/doxygen[dot]
		dev-libs/libxslt
	)
"

pkg_setup() {
	use gtk-doc && python-any-r1_pkg_setup
}

multilib_src_configure() {
	local emesonargs=(
		$(meson_native_use_bool gtk-doc build-documentation)
		-Dbuild-examples=false
		$(meson_use test build-tests)
		-Dboost-shared=true
	)
	meson_src_configure
}
