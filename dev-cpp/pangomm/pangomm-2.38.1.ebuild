# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"

inherit eutils gnome2 multilib-minimal

DESCRIPTION="C++ interface for pango"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="1.4"
KEYWORDS="*"

IUSE="doc"

COMMON_DEPEND="
	>=x11-libs/pango-1.38.0[${MULTILIB_USEDEP}]
	>=dev-cpp/glibmm-2.46.1:2[${MULTILIB_USEDEP}]
	>=dev-cpp/cairomm-1.2.2[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-2.3.2:2[${MULTILIB_USEDEP}]
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	doc? (
		media-gfx/graphviz
		dev-libs/libxslt
		app-doc/doxygen )
"
RDEPEND="${COMMON_DEPEND}
	!<dev-cpp/gtkmm-2.13:2.4
"

src_prepare() {
	# From GNOME
	# 	https://git.gnome.org/browse/pangomm/patch/?id=62ec4693bbf3c16eb1566b2cb499650f996f898f
	# 	https://git.gnome.org/browse/pangomm/patch/?id=52eb5216a89a0805a46cba39450d633b2c7ca4d4
	epatch "${FILESDIR}"/${P}-reduce-the-cairomm-dependency-back-to-1.2.2.patch
	epatch "${FILESDIR}"/${P}-enable-warnings-fata-use-the-same-warnings-as-glibmm-and-gtkmm.patch

	gnome2_src_prepare
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(multilib_native_use_enable doc documentation)
}

multilib_src_install() {
	gnome2_src_install
}
