# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Collection of GSettings schemas for GNOME desktop"
HOMEPAGE="https://git.gnome.org/browse/gsettings-desktop-schemas"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection"

RDEPEND="
	>=dev-libs/glib-2.31:2
	introspection? ( >=dev-libs/gobject-introspection-1.31.0:= )
	!<gnome-base/gdm-3.8
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.50.1
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure $(use_enable introspection)
}
