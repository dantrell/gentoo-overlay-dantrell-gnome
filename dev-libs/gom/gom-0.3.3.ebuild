# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_4,3_5,3_6} )

inherit gnome2 python-r1 meson

DESCRIPTION="GObject to SQLite object mapper library"
HOMEPAGE="https://wiki.gnome.org/Projects/Gom"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE="+introspection python"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} introspection )"

RDEPEND="
	>=dev-db/sqlite-3.7:3
	>=dev-libs/glib-2.36:2
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
	python? (
		${PYTHON_DEPS}
		>=dev-python/pygobject-3.16:3[${PYTHON_USEDEP}] )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.14
	>=dev-util/intltool-0.40.0
	sys-devel/gettext
	virtual/pkgconfig
	x11-libs/gdk-pixbuf:2
"
# TODO: make gdk-pixbuf properly optional with USE=test

pkg_setup() {
	use python && python_setup
}

src_prepare() {
	gnome2_src_prepare

	use python && python_copy_sources
}

src_configure() {
	local emasonargs=(
		-D enable-introspection=$(usex introspection true false)
	)
	meson_src_configure

	if use python ; then
		python_foreach_impl run_in_build_dir \
		gnome2_src_configure \
			${myconf[@]} \
			--enable-python
	fi
}

src_install() {
	meson_src_install

	if use python ; then
		docinto examples
		dodoc examples/*.py

		python_foreach_impl run_in_build_dir \
		emake DESTDIR="${D}" install-overridesPYTHON
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postinst() {
	gnome2_pkg_postinst
	gnome2_schemas_update
}
