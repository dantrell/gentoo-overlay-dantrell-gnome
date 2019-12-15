# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Gnome keyboard configuration library"
HOMEPAGE="https://www.gnome.org"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.18:2
	>=x11-libs/gtk+-2.91.7:3[X,introspection?]
	>=x11-libs/libxklavier-5.2[introspection?]

	introspection? ( >=dev-libs/gobject-introspection-0.6.7:= )
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		--disable-static \
		$(use_enable introspection) \
		$(use_enable test tests)
}
