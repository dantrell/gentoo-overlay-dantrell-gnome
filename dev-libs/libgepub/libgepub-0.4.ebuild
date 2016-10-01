# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="GObject based library for handling and rendering epub documents."
HOMEPAGE="https://github.com/GNOME/libgepub"

LICENSE="GPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	app-arch/libarchive
	>=dev-libs/glib-2.40
	dev-libs/libxml2
	net-libs/libsoup
	net-libs/webkit-gtk:4
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"
