# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GNOME_ORG_MODULE="gtk+"
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="xml"

inherit gnome.org python-single-r1

DESCRIPTION="Converts Glade files to GtkBuilder XML format"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# gtk-builder-convert was part of gtk+ until 2.24.10-r1
COMMON_DEPEND="${PYTHON_DEPS}"

RDEPEND="${COMMON_DEPEND}
	!<=x11-libs/gtk+-2.24.10:2
"

DEPEND="${COMMON_DEPEND}"

src_configure() { :; }

src_compile() { :; }

src_install() {
	cd gtk || die
	python_doscript gtk-builder-convert
}
