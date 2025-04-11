# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GCONF_DEBUG="yes"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome.org meson python-r1

DESCRIPTION="GObject to SQLite object mapper library"
HOMEPAGE="https://wiki.gnome.org/Projects/Gom"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="doc +introspection test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-db/sqlite-3.7:3
	>=dev-libs/glib-2.36:2
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
	${PYTHON_DEPS}
	>=dev-python/pygobject-3.16:3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
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
		$(meson_use introspection enable-introspection)
		$(meson_use doc enable-gtk-doc)
	)

	python_foreach_impl meson_src_configure
}

src_compile() {
	python_foreach_impl meson_src_compile
}

src_install() {
	docinto examples
	dodoc examples/*.py

	installing() {
		meson_src_install
		python_optimize
	}
	python_foreach_impl installing
}

src_test() {
	# tests may take a long time
	python_foreach_impl meson_src_test
}
