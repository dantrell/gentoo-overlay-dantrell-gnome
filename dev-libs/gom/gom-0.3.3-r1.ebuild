# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_4,3_5,3_6} )

inherit gnome2 python-r1 meson

DESCRIPTION="GObject to SQLite object mapper library"
HOMEPAGE="https://wiki.gnome.org/Projects/Gom"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	>=dev-db/sqlite-3.7:3
	>=dev-libs/glib-2.36:2
	>=dev-python/pygobject-3.16:3[${PYTHON_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.14
	>=dev-util/intltool-0.40.0
	sys-devel/gettext
	virtual/pkgconfig
	x11-libs/gdk-pixbuf:2
"

pkg_setup() {
	python_setup
}

src_configure() {
	local emesonargs=(
		-D enable-introspection=$(usex introspection true false)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
}

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postinst() {
	gnome2_pkg_postinst
	gnome2_schemas_update
}
