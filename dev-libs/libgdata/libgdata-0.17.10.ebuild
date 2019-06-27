# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 meson vala

DESCRIPTION="GLib-based library for accessing online service APIs using the GData protocol"
HOMEPAGE="https://wiki.gnome.org/Projects/libgdata"

LICENSE="LGPL-2.1+"
SLOT="0/22" # subslot = libgdata soname version
KEYWORDS=""

IUSE="+crypt gnome-online-accounts gtk gtk-doc +introspection test vala"
REQUIRED_USE="
	gnome-online-accounts? ( crypt )
	vala? ( introspection )
"

RDEPEND="
	>=dev-libs/glib-2.44.0:2
	>=dev-libs/json-glib-0.15[introspection?]
	>=dev-libs/libxml2-2:2
	>=net-libs/liboauth-0.9.4
	>=net-libs/libsoup-2.42.0:2.4[introspection?]
	>=x11-libs/gdk-pixbuf-2.14:2
	crypt? ( app-crypt/gcr:= )
	gnome-online-accounts? ( >=net-libs/gnome-online-accounts-3.8:=[introspection?,vala(+)?] )
	gtk? ( >=x11-libs/gtk+-2.91.2 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.7:= )
"
DEPEND="${RDEPEND}
	gtk-doc? ( >=dev-util/gtk-doc-am-1.25 )
	>=dev-util/intltool-0.40
	virtual/pkgconfig
	test? (
		>=net-libs/libsoup-2.55.90:2.4[introspection?]
		>=net-libs/uhttpmock-0.5
	)
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_feature gtk)
		$(meson_feature crypt gnome)
		$(meson_feature gnome-online-accounts goa)
		$(meson_use test always_build_tests)
		$(meson_use test installed_tests)
		-D man=true
		$(meson_use gtk-doc gtk_doc)
		$(meson_use introspection)
		$(meson_use vala vapi)
	)
	meson_src_configure
}

src_test() {
	unset ORBIT_SOCKETDIR
	virtx dbus-run-session meson test -C "${BUILD_DIR}" || die 'tests failed'
}
