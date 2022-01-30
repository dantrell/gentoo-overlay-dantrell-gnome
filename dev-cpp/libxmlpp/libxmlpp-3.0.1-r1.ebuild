# Distributed under the terms of the GNU General Public License v2

EAPI="8"

GNOME_ORG_MODULE="${PN/pp/++}"

inherit gnome2 multilib-minimal

DESCRIPTION="C++ wrapper for the libxml2 XML parser library"
HOMEPAGE="http://libxmlplusplus.sourceforge.net/"

LICENSE="LGPL-2.1"
SLOT="3.0"
KEYWORDS="*"

IUSE="doc"

RDEPEND="
	>=dev-libs/libxml2-2.7.7[${MULTILIB_USEDEP}]
	>=dev-cpp/glibmm-2.32:2[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

multilib_src_prepare() {
	gnome2_src_prepare
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(use_enable doc documentation)
}

multilib_src_install() {
	gnome2_src_install
}
