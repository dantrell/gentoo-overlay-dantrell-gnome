# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit flag-o-matic gnome2 multilib-minimal

DESCRIPTION="C++ interface for pango"
HOMEPAGE="https://www.gtkmm.org https://gitlab.gnome.org/GNOME/pangomm"

LICENSE="LGPL-2.1+"
SLOT="1.4"
KEYWORDS="*"

IUSE="gtk-doc"

DEPEND="
	>=x11-libs/pango-1.36[${MULTILIB_USEDEP}]
	>=dev-cpp/glibmm-2.36.0:2[${MULTILIB_USEDEP}]
	>=dev-cpp/cairomm-1.10.0-r1[${MULTILIB_USEDEP}]
	dev-libs/libsigc++:2=[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-2.3.2:2[${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? (
		media-gfx/graphviz
		dev-libs/libxslt
		app-text/doxygen
	)
"

multilib_src_configure() {
	# Code is not C++17 ready (GCC 11 default)
	append-cxxflags -std=c++14

	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(multilib_native_use_enable gtk-doc documentation)
}

multilib_src_install() {
	gnome2_src_install
}
