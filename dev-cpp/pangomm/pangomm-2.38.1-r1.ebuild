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
	>=x11-libs/pango-1.38.0[${MULTILIB_USEDEP}]
	>=dev-cpp/glibmm-2.46.1:2[${MULTILIB_USEDEP}]
	>=dev-cpp/cairomm-1.2.2[${MULTILIB_USEDEP}]
	dev-libs/libsigc++:2=[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-2.3.2:2[${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? (
		media-gfx/graphviz
		dev-libs/libxslt
		app-doc/doxygen
	)
"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/pangomm/commit/62ec4693bbf3c16eb1566b2cb499650f996f898f
	# 	https://gitlab.gnome.org/GNOME/pangomm/commit/52eb5216a89a0805a46cba39450d633b2c7ca4d4
	eapply "${FILESDIR}"/${PN}-2.38.1-reduce-the-cairomm-dependency-back-to-1.2.2.patch
	eapply "${FILESDIR}"/${PN}-2.38.1-enable-warnings-fata-use-the-same-warnings-as-glibmm-and-gtkmm.patch

	gnome2_src_prepare
}

multilib_src_configure() {
	# Code is not C++17 ready (GCC 11 default)
	append-cxxflags -std=c++14

	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(multilib_native_use_enable gtk-doc documentation)
}

multilib_src_install() {
	gnome2_src_install
}
