# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit autotools gnome2 vala

DESCRIPTION="GLib-based library for accessing online service APIs using the GData protocol"
HOMEPAGE="https://wiki.gnome.org/Projects/libgdata"

LICENSE="LGPL-2.1+"
SLOT="0/22" # subslot = libgdata soname version
KEYWORDS="*"

IUSE="+crypt gnome-online-accounts +introspection static-libs test vala"
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
	introspection? ( >=dev-libs/gobject-introspection-0.9.7:= )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.25
	>=dev-util/intltool-0.40
	virtual/pkgconfig
	test? (
		>=net-libs/libsoup-2.55.90:2.4[introspection?]
		>=net-libs/uhttpmock-0.5
	)
	vala? ( $(vala_depend) )
"

src_prepare() {
	if has_version "<net-libs/libsoup-2.55.90:2.4"; then
		# From GNOME:
		# 	https://git.gnome.org/browse/libgdata/commit/?id=b87141e748b108cd9e56a70635a6ade097d54ab5
		# 	https://git.gnome.org/browse/libgdata/commit/?id=b1115818eb0aa8d8f171df06c7a2e9a6fbac073c
		eapply -R "${FILESDIR}"/${PN}-0.17.8-use-the-correct-type-for-gtk-show-uri-for-window.patch
		eapply -R "${FILESDIR}"/${PN}-0.17.8-demos-use-non-deprecated-api.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.17.8-disable-demos.patch

	eautoreconf
	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-build-demos \
		$(use_enable crypt gnome) \
		$(use_enable gnome-online-accounts goa) \
		$(use_enable introspection) \
		$(use_enable vala) \
		$(use_enable static-libs static) \
		$(use_enable test always-build-tests)
}

src_test() {
	unset ORBIT_SOCKETDIR
	dbus-run-session emake check
}
