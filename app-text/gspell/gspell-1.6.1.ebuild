# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2 vala virtualx

DESCRIPTION="Spell check library for GTK+ applications"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gspell"

LICENSE="LGPL-2.1+"
SLOT="0/1" # subslot = libgspell-1 soname version
KEYWORDS="*"

IUSE="+introspection vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=app-text/enchant-1.6.0:0=
	>=dev-libs/glib-2.44:2
	>=x11-libs/gtk+-3.20:3[introspection?]
	app-text/iso-codes
	introspection? ( >=dev-libs/gobject-introspection-1.42.0:= )
"
DEPEND="${RDEPEND}
	test? ( sys-apps/dbus )
"
BDEPEND="
	dev-libs/libxml2:2
	>=dev-util/gtk-doc-am-1.25
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_setup
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(use_enable introspection) \
		$(use_enable vala)
}

src_test() {
	virtx dbus-run-session emake check
}
