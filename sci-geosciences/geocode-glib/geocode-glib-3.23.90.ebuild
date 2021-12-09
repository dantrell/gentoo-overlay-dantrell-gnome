# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="GLib helper library for geocoding services"
HOMEPAGE="https://gitlab.gnome.org/GNOME/geocode-glib"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection test"

# FIXME: need network #424719, recheck
# need various locales to be present
RESTRICT="test"

RDEPEND="
	>=dev-libs/glib-2.44:2
	>=dev-libs/json-glib-0.99.2[introspection?]
	gnome-base/gvfs[http]
	>=net-libs/libsoup-2.42:2.4[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-0.6.3:= )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.13
	>=sys-devel/gettext-0.19.6
	virtual/pkgconfig
	test? ( sys-apps/dbus )
"
# eautoreconf requires:
#	dev-libs/gobject-introspection-common
#	gnome-base/gnome-common

src_configure() {
	gnome2_src_configure $(use_enable introspection)
}

src_test() {
	export GVFS_DISABLE_FUSE=1
	export GIO_USE_VFS=gvfs
	ewarn "Tests require network access to http://where.yahooapis.com"
	dbus-launch emake check
}
