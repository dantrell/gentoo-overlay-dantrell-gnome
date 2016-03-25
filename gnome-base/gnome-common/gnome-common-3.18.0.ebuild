# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Common files for development of Gnome packages"
HOMEPAGE="https://git.gnome.org/browse/gnome-common"

LICENSE="GPL-3"
SLOT="3"
KEYWORDS="*"

IUSE="+autoconf-archive"

RDEPEND="autoconf-archive? ( >=sys-devel/autoconf-archive-2015.02.04 )
	!autoconf-archive? ( !>=sys-devel/autoconf-archive-2015.02.04 )
"
DEPEND=""

src_configure() {
	gnome2_src_configure \
		$(use_with autoconf-archive)
}
