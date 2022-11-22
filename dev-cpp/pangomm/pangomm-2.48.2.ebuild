# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_8,3_9,3_10,3_11} )

inherit gnome.org meson-multilib python-any-r1

DESCRIPTION="C++ interface for pango"
HOMEPAGE="https://www.gtkmm.org https://gitlab.gnome.org/GNOME/pangomm"

LICENSE="LGPL-2.1+"
SLOT="2.48"
KEYWORDS="*"

IUSE="gtk-doc"

DEPEND="
	>=dev-cpp/cairomm-1.16.0:1.16[gtk-doc?,${MULTILIB_USEDEP}]
	>=dev-cpp/glibmm-2.68.0:2.68[gtk-doc?,${MULTILIB_USEDEP}]
	dev-libs/libsigc++:3=[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-3:3[gtk-doc?,${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.48.0[${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? (
		app-doc/doxygen[dot]
		dev-lang/perl
		dev-libs/libxslt
	)
	${PYTHON_DEPS}
"

multilib_src_configure() {
	local emesonargs=(
		-Dmaintainer-mode=false
		$(meson_native_use_bool gtk-doc build-documentation)
	)
	meson_src_configure
}
