# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="GObject based library for handling and rendering epub documents"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libgepub"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection"

RDEPEND="
	app-arch/libarchive
	dev-libs/glib:2
	dev-libs/libxml2
	net-libs/libsoup:2.4
	net-libs/webkit-gtk:4[introspection?]
	x11-libs/gtk+:3
	introspection? ( >=dev-libs/gobject-introspection-1.30:= )
"
DEPEND="${RDEPEND}
	gnome-base/gnome-common
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		--disable-static \
		$(use_enable introspection)
}
