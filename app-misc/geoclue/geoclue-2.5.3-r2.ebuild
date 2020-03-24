# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit meson systemd vala user xdg

DESCRIPTION="A location information D-Bus service"
HOMEPAGE="https://gitlab.freedesktop.org/geoclue/geoclue/wikis/home"
SRC_URI="https://gitlab.freedesktop.org/geoclue/${PN}/-/archive/${PV}/${P}.tar.bz2"

LICENSE="LGPL-2.1+ GPL-2+"
SLOT="2.0"
KEYWORDS="~*"

IUSE="+introspection gtk-doc modemmanager vala zeroconf"
REQUIRED_USE="vala? ( introspection )"

DEPEND="
	>=dev-libs/glib-2.42:2
	>=dev-libs/json-glib-0.14.0
	>=net-libs/libsoup-2.42.0:2.4
	introspection? ( >=dev-libs/gobject-introspection-0.9.6:= )
	modemmanager? ( >=net-misc/modemmanager-1.6 )
	zeroconf? ( >=net-dns/avahi-0.6.10[dbus] )
	x11-libs/libnotify
"
RDEPEND="${DEPEND}
	sys-apps/dbus
"
BDEPEND="
	dev-util/gdbus-codegen
	gtk-doc? (
		app-text/docbook-xml-dtd:4.1.2
		>=dev-util/gtk-doc-1 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-2.5.3-optional-vapi.patch

	# From GeoClue:
	# 	https://cgit.freedesktop.org/geoclue/commit/?h=2.4.x&id=5ae456312c941ba2951563de0aef64ca5c25b0e6
	"${FILESDIR}"/${PN}-2.5.3-lower-the-minimum-required-glib-version.patch
)

src_prepare() {
	xdg_src_prepare
	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dlibgeoclue=true
		$(meson_use introspection)
		$(meson_use vala vapi)
		$(meson_use gtk-doc)
		$(meson_use modemmanager 3g-source)
		$(meson_use modemmanager cdma-source)
		$(meson_use modemmanager modem-gps-source)
		$(meson_use zeroconf nmea-source)
		-Denable-backend=true
		-Ddemo-agent=true
		-Dsystemd-system-unit-dir="$(systemd_get_systemunitdir)"
		-Ddbus-srv-user=geoclue
	)
	meson_src_configure
}

pkg_preinst() {
	enewgroup geoclue
	enewuser geoclue -1 -1 /var/lib/geoclue geoclue
}
