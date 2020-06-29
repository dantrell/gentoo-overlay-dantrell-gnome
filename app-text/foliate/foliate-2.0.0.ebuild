# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit meson

DESCRIPTION="Simple and modern eBook viewer"
HOMEPAGE="https://johnfactotum.github.io/foliate/"
SRC_URI="https://github.com/johnfactotum/foliate/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	app-text/gspell
	dev-libs/gjs
	net-libs/webkit-gtk
"
DEPEND="
	${RDEPEND}
	dev-util/meson
	sys-devel/gettext
"
