# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_8,3_9,3_10,3_11} )

inherit gnome.org meson-multilib python-any-r1

DESCRIPTION="C++ interface for pango"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="1.4"
KEYWORDS="~*"

IUSE="doc"

DEPEND="
	>=dev-cpp/cairomm-1.2.2:0[doc?,${MULTILIB_USEDEP}]
	>=dev-cpp/glibmm-2.48.0:2[doc?,${MULTILIB_USEDEP}]
	dev-libs/libsigc++:2=[${MULTILIB_USEDEP}]
	dev-libs/libsigc++:2[doc?,${MULTILIB_USEDEP}]
	<x11-libs/pango-1.50.0[${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.41.0[${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? (
		app-doc/doxygen[dot]
		dev-lang/perl
		dev-libs/libxslt
	)
	${PYTHON_DEPS}
"

multilib_src_configure() {
	local emesonargs=(
		-Dmaintainer-mode=false
		$(meson_native_use_bool doc build-documentation)
	)
	meson_src_configure
}
