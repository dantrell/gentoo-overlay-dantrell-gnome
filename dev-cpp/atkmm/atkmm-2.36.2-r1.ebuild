# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome.org meson-multilib python-any-r1

DESCRIPTION="C++ interface for the ATK library"
HOMEPAGE="https://www.gtkmm.org https://gitlab.gnome.org/GNOME/atkmm"

LICENSE="LGPL-2.1+"
SLOT="2.36"
KEYWORDS="*"

IUSE="gtk-doc"

DEPEND="
	>=dev-cpp/glibmm-2.68.0:2.68[gtk-doc?,${MULTILIB_USEDEP}]
	>=dev-libs/atk-2.33.3[${MULTILIB_USEDEP}]
	dev-libs/libsigc++:3[gtk-doc?,${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? (
		app-text/doxygen[dot]
		dev-lang/perl
		dev-libs/libxslt
	)
	${PYTHON_DEPS}
"

multilib_src_configure() {
	local emesonargs=(
		$(meson_native_use_bool gtk-doc build-documentation)
	)
	meson_src_configure
}
