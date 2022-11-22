# Distributed under the terms of the GNU General Public License v2

EAPI="8"

GNOME_TARBALL_SUFFIX="bz2"

inherit gnome2

DESCRIPTION="CORBA tree builder"
HOMEPAGE="https://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND=">=dev-libs/glib-2.4.0:2"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/flex
	virtual/yacc
	virtual/pkgconfig
"
