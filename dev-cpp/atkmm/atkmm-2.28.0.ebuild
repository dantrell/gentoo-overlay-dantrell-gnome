# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2 multilib-minimal

DESCRIPTION="C++ interface for the ATK library"
HOMEPAGE="https://www.gtkmm.org https://gitlab.gnome.org/GNOME/atkmm"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk-doc"

DEPEND="
	>=dev-cpp/glibmm-2.46.2:2[gtk-doc?,${MULTILIB_USEDEP}]
	>=dev-libs/atk-2.18.0[${MULTILIB_USEDEP}]
	dev-libs/libsigc++:2=[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-2.3.2:2[gtk-doc?,${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
"

multilib_src_configure() {
	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(multilib_native_use_enable gtk-doc documentation)
}

multilib_src_install() {
	gnome2_src_install
}
