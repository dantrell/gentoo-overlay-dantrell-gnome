# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2

DESCRIPTION="Automatic archives creating and extracting library"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-autoar"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk +introspection"

RDEPEND="
	>=app-arch/libarchive-3.2.0
	>=dev-libs/glib-2.35.6:2
	gtk? ( >=x11-libs/gtk+-3.2:3 )
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/gtk-doc-am-1.14
	gnome-base/gnome-common
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		--disable-static \
		$(use_enable introspection) \
		$(use_enable gtk)
}
