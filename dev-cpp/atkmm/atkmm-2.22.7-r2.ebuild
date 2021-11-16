# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit flag-o-matic gnome2 multilib-minimal

DESCRIPTION="C++ interface for the ATK library"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="doc"

COMMON_DEPEND="
	>=dev-cpp/glibmm-2.36.0:2[doc?,${MULTILIB_USEDEP}]
	>=dev-libs/atk-2.8.0[${MULTILIB_USEDEP}]
	dev-libs/libsigc++:2=[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-2.3.2:2[${MULTILIB_USEDEP}]
"
RDEPEND="${COMMON_DEPEND}
	!<dev-cpp/gtkmm-2.22.0
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

multilib_src_configure() {
	# Code is not C++17 ready (GCC 11 default)
	append-cxxflags -std=c++14

	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(multilib_native_use_enable doc documentation)
}

multilib_src_install() {
	gnome2_src_install
}
