# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome2 systemd versionator

MY_PV=$(get_version_component_range 1-2)

DESCRIPTION="A geoinformation D-Bus service"
HOMEPAGE="https://freedesktop.org/wiki/Software/GeoClue"
SRC_URI="https://www.freedesktop.org/software/${PN}/releases/${MY_PV}/${P}.tar.xz"

LICENSE="LGPL-2"
SLOT="2.0"
KEYWORDS="*"

IUSE="+introspection modemmanager zeroconf"

DEPEND="
	>=dev-libs/glib-2.34:2
	>=dev-libs/json-glib-0.14
	>=net-libs/libsoup-2.42:2.4
	introspection? ( >=dev-libs/gobject-introspection-0.9.6:= )
	modemmanager? ( >=net-misc/modemmanager-1 )
	zeroconf? ( >=net-dns/avahi-0.6.10[dbus] )
"
RDEPEND="${DEPEND}
	acct-user/geoclue
	sys-apps/dbus
"
BDEPEND="
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	eapply "${FILESDIR}"/${PN}-2.4.1-fix-GLIBC-features.patch

	# From GeoClue:
	# 	https://cgit.freedesktop.org/geoclue/commit/?id=7414f60e8849a6fdeba8827197721b3d36c48754
	# 	https://cgit.freedesktop.org/geoclue/commit/?id=595bb7f5e9d4e784656ab381da8014d8ea1e10c8
	# 	https://cgit.freedesktop.org/geoclue/commit/?id=1194c23407f04153e541d4dc636e1dfa83786624
	# 	https://cgit.freedesktop.org/geoclue/commit/?id=4cefb6bf6d1835776e687f7302967e4ba9c22335
	eapply "${FILESDIR}"/${PN}-2.4.2-gir-correct-namespace-version.patch
	eapply "${FILESDIR}"/${PN}-2.4.3-lib-clear-the-task-pointer-when-unrefing.patch
	eapply "${FILESDIR}"/${PN}-2.4.4-main-remove-stray-semicolon.patch
	eapply "${FILESDIR}"/${PN}-2.4.4-service-client-fix-comparison-against-zero.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	# debug only affects CFLAGS
	gnome2_src_configure \
		--with-dbus-service-user=geoclue \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
		$(use_enable introspection) \
		$(use_enable modemmanager 3g-source) \
		$(use_enable modemmanager cdma-source) \
		$(use_enable modemmanager modem-gps-source) \
		$(use_enable zeroconf nmea-source)
}
