# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala

DESCRIPTION="Utility library aiming to ease the handling UPnP A/V profiles"
HOMEPAGE="https://wiki.gnome.org/Projects/GUPnP https://gitlab.gnome.org/GNOME/gupnp-av"

LICENSE="LGPL-2"
SLOT="0/2" # subslot: soname version
KEYWORDS="*"

IUSE="+introspection"

RDEPEND="
	>=dev-libs/glib-2.38:2
	>=net-libs/libsoup-2.28.2:2.4[introspection?]
	dev-libs/libxml2
	introspection? ( >=dev-libs/gobject-introspection-1.36:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	>=dev-build/gtk-doc-am-1.10
	introspection? ( $(vala_depend) )
"

src_prepare() {
	use introspection && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(use_enable introspection) \
		--disable-static
}
