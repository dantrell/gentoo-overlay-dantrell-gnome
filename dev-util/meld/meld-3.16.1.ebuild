# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_REQ_USE="xml"
PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

inherit gnome2 distutils-r1

DESCRIPTION="A graphical diff and merge tool"
HOMEPAGE="http://meldmerge.org/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.36:2[dbus]
	dev-python/dbus-python[${PYTHON_USEDEP}]
	>=dev-python/pygobject-3.8:3[cairo,${PYTHON_USEDEP}]
	gnome-base/gsettings-desktop-schemas
	>=x11-libs/gtk+-3.14:3[introspection]
	>=x11-libs/gtksourceview-3.14:3.0[introspection]
	x11-themes/hicolor-icon-theme
"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/itstool
	sys-devel/gettext
"

src_prepare() {
	# From GNOME:
	# 	https://git.gnome.org/browse/meld/commit/?id=30a656e22c3111b257f8bdbdaedea5f6b4066b5f
	# 	https://git.gnome.org/browse/meld/commit/?id=d176eae8283bcff563d995aed460f17062220d99
	# 	https://git.gnome.org/browse/meld/commit/?id=de6061ad7aab445812636447e52258eec5d3dc77
	eapply "${FILESDIR}"/${PN}-3.16.2-sourceview-fix-custom-candidate-return.patch
	eapply "${FILESDIR}"/${PN}-3.16.2-misc-fix-performance-of-interval-merging.patch
	eapply "${FILESDIR}"/${PN}-3.16.2-misc-avoid-string-copies-during-filtering.patch

	gnome2_src_prepare
}

python_compile_all() {
	mydistutilsargs=( --no-update-icon-cache --no-compile-schemas )
}
