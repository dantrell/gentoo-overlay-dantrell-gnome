# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala

DESCRIPTION="Automatic archives creating and extracting library"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-autoar"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk +introspection vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=app-arch/libarchive-3.4.0
	>=dev-libs/glib-2.55.2:2
	gtk? ( >=x11-libs/gtk+-3.2:3[introspection?] )
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/gtk-doc-am-1.14
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		$(use_enable introspection) \
		$(use_enable vala) \
		$(use_enable gtk)
}
