# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="C++ bindings for gtksourceview"
HOMEPAGE="https://wiki.gnome.org/Projects/GtkSourceView"

LICENSE="LGPL-2.1"
SLOT="3.0"
KEYWORDS="*"

IUSE="doc"

RDEPEND="
	>=dev-cpp/glibmm-2.46.1:2
	>=dev-cpp/gtkmm-3.18.0:3.0
	>=x11-libs/gtksourceview-3.18.0:3.0

	dev-cpp/atkmm
	dev-cpp/cairomm
	dev-cpp/pangomm:1.4
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"

src_configure() {
	gnome2_src_configure $(use_enable doc documentation)
}
