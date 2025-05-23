# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_REQ_USE="xml(+)"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
DISTUTILS_SINGLE_IMPL=1

inherit gnome2 distutils-r1

DESCRIPTION="A graphical diff and merge tool"
HOMEPAGE="http://meldmerge.org/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.50:2[dbus]
	$(python_gen_cond_dep '
		>=dev-python/pygobject-3.12:3[cairo,${PYTHON_USEDEP}]
	')
	gnome-base/gsettings-desktop-schemas
	>=x11-libs/gtk+-3.14:3[introspection]
	>=x11-libs/gtksourceview-3.14:3.0[introspection]
	>=x11-libs/pango-1.34[introspection]
	x11-themes/hicolor-icon-theme
"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/itstool
	sys-devel/gettext
"

python_compile_all() {
	mydistutilsargs=( --no-update-icon-cache --no-compile-schemas )
}
