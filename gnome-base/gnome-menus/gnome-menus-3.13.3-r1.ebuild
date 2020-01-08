# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Library and layout configuration for the Desktop Menu fd.o specification"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-menus"

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
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
	test? ( dev-libs/gjs )
"

src_prepare() {
	# Don't show KDE standalone settings desktop files in GNOME others menu
	eapply "${FILESDIR}"/${PN}-3.8.0-ignore_kde_standalone.patch

	# desktop-entries: support multiple desktops in XDG_CURRENT_DESKTOP
	# (from 'master')
	eapply "${FILESDIR}"/${PN}-3.13.3-multiple-desktop{,2}.patch

	gnome2_src_prepare
}

src_configure() {
	# Do NOT compile with --disable-debug/--enable-debug=no
	# It disables api usage checks
	gnome2_src_configure \
		$(use_enable introspection) \
		--disable-static
}
