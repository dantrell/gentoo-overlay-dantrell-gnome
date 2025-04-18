# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
PYTHON_REQ_USE="xml(+)"

inherit gnome2 python-single-r1

DESCRIPTION="Simple GNOME menu editor"
HOMEPAGE="https://gitlab.gnome.org/GNOME/alacarte"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
	>=gnome-base/gnome-menus-3.5.3:3[introspection]
"
RDEPEND="${COMMON_DEPEND}
	x11-libs/gdk-pixbuf:2[introspection]
	x11-libs/gtk+:3[introspection]
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.40.0
	sys-devel/gettext
	virtual/pkgconfig
"

src_install() {
	gnome2_src_install
	python_optimize
}
