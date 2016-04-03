# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"

inherit eutils gnome2 systemd user versionator

MY_PV=$(get_version_component_range 1-2)
DESCRIPTION="A geoinformation D-Bus service"
HOMEPAGE="http://freedesktop.org/wiki/Software/GeoClue"
SRC_URI="http://www.freedesktop.org/software/${PN}/releases/${MY_PV}/${P}.tar.xz"

LICENSE="LGPL-2"
SLOT="2.0"
KEYWORDS="~*"

IUSE="+introspection +modemmanager zeroconf"

RESTRICT="mirror"

RDEPEND="
	>=dev-libs/glib-2.34:2
	>=dev-libs/json-glib-0.14
	>=net-libs/libsoup-2.42:2.4
	sys-apps/dbus
	introspection? ( >=dev-libs/gobject-introspection-0.9.6:= )
	modemmanager? ( >=net-misc/modemmanager-1 )
	zeroconf? ( >=net-dns/avahi-0.6.10 )
	!<sci-geosciences/geocode-glib-3.10.0
"
DEPEND="${RDEPEND}
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	# From Upstream:
	#.	https://cgit.freedesktop.org/geoclue/commit/?id=1194c23407f04153e541d4dc636e1dfa83786624
	#.	https://cgit.freedesktop.org/geoclue/commit/?id=4cefb6bf6d1835776e687f7302967e4ba9c22335
	epatch "${FILESDIR}"/${P}-main-remove-stray-semicolon.patch
	epatch "${FILESDIR}"/${P}-service-client-fix-comparison-against-zero.patch
}

src_configure() {
	# debug only affects CFLAGS
	gnome2_src_configure \
		--with-dbus-service-user=geoclue \
		$(use_enable introspection) \
		$(use_enable modemmanager 3g-source) \
		$(use_enable modemmanager cdma-source) \
		$(use_enable modemmanager modem-gps-source) \
		$(use_enable zeroconf nmea-source) \
		$(systemd_with_unitdir)
}

pkg_preinst() {
	enewgroup geoclue
	enewuser geoclue -1 -1 /var/lib/geoclue geoclue
}
