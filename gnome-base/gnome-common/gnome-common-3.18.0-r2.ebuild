# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2

DESCRIPTION="Common files for development of Gnome packages"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-common"

LICENSE="GPL-3"
SLOT="3"
KEYWORDS="*"

src_configure() {
	# Force people to rely on sys-devel/autoconf-archive, bug #594084
	gnome2_src_configure --with-autoconf-archive
}
