# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_EAUTORECONF="yes"

inherit gnome2

DESCRIPTION="Library and layout configuration for the Desktop Menu fd.o specification"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-menus"
SRC_URI="https://gitlab.gnome.org/GNOME/${PN}/-/archive/${PV}/${P}.tar.bz2"

LICENSE="GPL-2+ LGPL-2+"
SLOT="3"
KEYWORDS="*"

IUSE="+introspection test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.29.15:2
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
	test? ( dev-libs/gjs )
"

src_configure() {
	# Do NOT compile with --disable-debug/--enable-debug=no
	# It disables api usage checks
	gnome2_src_configure \
		$(use_enable introspection) \
		--disable-static
}
