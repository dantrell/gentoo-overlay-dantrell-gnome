# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2 multilib-minimal

DESCRIPTION="C++ interface for pango"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="1.4"
KEYWORDS="*"

IUSE="doc"

DEPEND="
	>=dev-cpp/cairomm-1.2.2:0[${MULTILIB_USEDEP}]
	>=dev-cpp/glibmm-2.48.0:2[${MULTILIB_USEDEP}]
	dev-libs/libsigc++:2=[${MULTILIB_USEDEP}]
	dev-libs/libsigc++:2[${MULTILIB_USEDEP}]
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
"

multilib_src_configure() {
	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(multilib_native_use_enable doc documentation)
}

multilib_src_install() {
	gnome2_src_install
}
