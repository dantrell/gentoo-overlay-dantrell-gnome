# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Collection of tools for building and converting documentation"
HOMEPAGE="https://wiki.gnome.org/Apps/Yelp/Tools"

LICENSE="|| ( GPL-2+ freedist ) GPL-2+" # yelp.m4 is GPL2 || freely distributable
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/libxml2-2.6.12
	>=dev-libs/libxslt-1.1.8
	dev-util/itstool
	>=gnome-extra/yelp-xsl-3.17.3
	virtual/awk
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"
