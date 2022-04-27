# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_8,3_9,3_10} )

inherit gnome.org meson-multilib python-any-r1

DESCRIPTION="C++ interface for pango"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="2.48"
KEYWORDS="*"

IUSE="doc"

DEPEND="
	>=dev-cpp/cairomm-1.16.0:1.16[doc?,${MULTILIB_USEDEP}]
	>=dev-cpp/glibmm-2.68.0:2.68[doc?,${MULTILIB_USEDEP}]
	dev-libs/libsigc++:3=[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-3:3[doc?,${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.48.0[${MULTILIB_USEDEP}]
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