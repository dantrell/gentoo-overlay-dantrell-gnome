# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2

DESCRIPTION="Build molecules out of isolated atoms"
HOMEPAGE="https://wiki.gnome.org/Apps/Atomix"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=x11-libs/gtk+-3.10:3
	>=x11-libs/gdk-pixbuf-2.0.5:2
	>=dev-libs/glib-2.36.0:2
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/appstream-glib
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
"
