# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_8,3_9,3_10} )

inherit meson python-single-r1

DESCRIPTION="Simple and modern eBook viewer"
HOMEPAGE="https://johnfactotum.github.io/foliate/"
SRC_URI="https://github.com/johnfactotum/foliate/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

IUSE="python"

RDEPEND="
	app-text/gspell
	dev-libs/gjs
	net-libs/webkit-gtk
"
DEPEND="
	${RDEPEND}
	python? (
		${PYTHON_DEPS}
	)
	dev-util/meson
	sys-devel/gettext
"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}
