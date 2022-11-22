# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit multilib-build

DESCRIPTION="GNOME plugin for libsoup"
HOMEPAGE="https://wiki.gnome.org/LibSoup"
SRC_URI="${SRC_URI//-gnome}"

LICENSE="LGPL-2+"
SLOT="2.4"
KEYWORDS="*"

IUSE="+introspection"

RDEPEND="
	~net-libs/libsoup-${PV}[introspection?,${MULTILIB_USEDEP}]
"
