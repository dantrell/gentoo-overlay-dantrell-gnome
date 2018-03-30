# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_4,3_5,3_6} )

inherit autotools gnome2 python-any-r1 vala

DESCRIPTION="Collection of data extractors for Tracker"
HOMEPAGE="https://wiki.gnome.org/Projects/Tracker"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0/100"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=app-misc/tracker-2
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	$(vala_depend)
"

src_prepare() {
	eautoreconf # See bug #367975
	gnome2_src_prepare
	vala_src_prepare
}
