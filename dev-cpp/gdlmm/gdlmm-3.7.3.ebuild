# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2 multilib-minimal

DESCRIPTION="C++ bindings for the gdl library"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="*"

IUSE="doc"

RESTRICT="mirror"

RDEPEND="
	>=dev-libs/gdl-3.7[${MULTILIB_USEDEP}]
	>=dev-cpp/glibmm-2.16[${MULTILIB_USEDEP}]
	>=dev-cpp/gtkmm-3.0[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

multilib_src_configure() {
	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(multilib_native_use_enable doc documentation)
}

multilib_src_install() {
	gnome2_src_install
}
