# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"
VAPA_API_MIN_VERSION="0.24"

inherit gnome2 vala

DESCRIPTION="Manage your online calendars with simple and modern interface"
HOMEPAGE="https://wiki.gnome.org/Apps/California"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	>=dev-libs/glib-2.38:2
	>=dev-libs/gobject-introspection-1.38
	>=dev-libs/libgdata-0.14
	>=dev-libs/libgee-0.10.5:0.8
	>=net-libs/gnome-online-accounts-3.8.3
	>=net-libs/libsoup-2.44:2.4
	>=gnome-extra/evolution-data-server-3.8
	<gnome-extra/evolution-data-server-3.13.90
	<mail-client/evolution-3.13.90
	>=x11-libs/gtk+-3.12.2:3
	x11-misc/xdg-utils
"
DEPEND="${RDEPEND}
	$(vala_depend)
	app-text/yelp-tools
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_install() {
	# FIXME: report doc install being broken upstream
	gnome2_src_install

	rm -rf "${ED}"/usr/doc || die
}
