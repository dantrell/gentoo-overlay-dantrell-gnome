# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala virtualx

DESCRIPTION="Spell check library for GTK+ applications"
HOMEPAGE="https://wiki.gnome.org/Projects/gspell"

LICENSE="LGPL-2.1+"
SLOT="0/1" # subslot = libgspell-1 soname version
KEYWORDS="*"

IUSE="+introspection vala"
REQUIRED_USE="vala? ( introspection )"

DEPEND="
	>=app-text/enchant-1.6.0:0=
	>=dev-libs/glib-2.44:2
	>=x11-libs/gtk+-3.20:3[introspection?]
	app-text/iso-codes
	introspection? ( >=dev-libs/gobject-introspection-1.42.0:= )
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-libs/libxml2:2
	>=dev-util/gtk-doc-am-1.25
	>=dev-util/intltool-0.35.0
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(use_enable introspection) \
		$(use_enable vala)
}

src_test() {
	virtx emake check
}
