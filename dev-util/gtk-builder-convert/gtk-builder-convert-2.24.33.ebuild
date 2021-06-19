# Distributed under the terms of the GNU General Public License v2

EAPI="7"

GNOME_ORG_MODULE="gtk+"
PYTHON_COMPAT=( python{3_8,3_9,3_10} )
PYTHON_REQ_USE="xml"

inherit gnome.org python-single-r1

DESCRIPTION="Converts Glade files to GtkBuilder XML format"
HOMEPAGE="https://www.gtk.org/"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~*"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# gtk-builder-convert was part of gtk+ until 2.24.10-r1
# man page transitioned in 2.24.31-r1
RDEPEND="${PYTHON_DEPS}
	!<x11-libs/gtk+-2.24.31-r1:2
"
BDEPEND="${PYTHON_DEPS}
	app-text/docbook-xml-dtd:4.3
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
"

src_configure() { :; }

src_compile() {
	xsltproc -nonet http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl docs/reference/gtk/gtk-builder-convert.xml || die
}

src_install() {
	doman gtk-builder-convert.1
	python_doscript gtk/gtk-builder-convert
}
