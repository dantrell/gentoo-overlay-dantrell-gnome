# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit distutils-r1 gnome2-utils xdg

DESCRIPTION="Graph plotting app for GNOME"
HOMEPAGE="https://github.com/alexhuntley/Plots"
SRC_URI="https://github.com/alexhuntley/Plots/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P/p/P}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~*"

IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-python/pygobject:3
	dev-python/pycairo
	gui-libs/gtk:4
	gui-libs/libhandy:1

	>=dev-python/pyopengl-3.1.6
	>=dev-python/jinja-3.1.1
	>=dev-python/numpy-1.22.3
	>=dev-python/lark-1.1.2

	>=dev-python/pyglm-2.5.7
	>=dev-python/freetype-py-2.2.0
"
DEPEND="${RDEPEND}
"
BDEPEND="
	sys-devel/gettext
"

python_prepare_all() {
	distutils-r1_python_prepare_all
}

python_install_all() {
	distutils-r1_python_install_all
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
