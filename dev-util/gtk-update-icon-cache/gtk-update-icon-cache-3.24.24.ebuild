# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit meson

DESCRIPTION="GTK update icon cache"
HOMEPAGE="https://www.gtk.org/ https://gitlab.gnome.org/Community/gentoo/gtk-update-icon-cache"
SRC_URI="https://gitlab.gnome.org/Community/gentoo/${PN}/-/archive/${PV}/${P}.tar.bz2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.53.4:2
	>=x11-libs/gdk-pixbuf-2.30:2
	!<x11-libs/gtk+-3.22.0:3
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.3
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"
