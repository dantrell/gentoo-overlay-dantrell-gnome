# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala virtualx

DESCRIPTION="GtkSourceView-based text editors and IDE helper library"
HOMEPAGE="https://gitlab.gnome.org/swilmet/tepl"

LICENSE="LGPL-2.1+"
SLOT="4"
KEYWORDS="*"

IUSE="+introspection test vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

RDEPEND="
	>=gui-libs/amtk-4.0
	>=dev-libs/glib-2.52:2
	>=x11-libs/gtk+-3.20
	>=x11-libs/gtksourceview-4.0:4
	>=dev-libs/libxml2-2.5
	app-i18n/uchardet
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
DEPEND="${RDEPEND}
	test? ( dev-debug/valgrind )
	vala? ( $(vala_depend) )
	>=sys-devel/gettext-0.19.4
	>=dev-build/gtk-doc-am-1.25
	virtual/pkgconfig
"

src_prepare() {
	# requires running gvfs-metadata
	sed -e 's:\(g_test_add_func.*/file/load_save_metadata_sync.*\):/*\1*/:' \
		-e 's:\(g_test_add_func.*/file/load_save_metadata_async.*\):/*\1*/:' \
		-e 's:\(g_test_add_func.*/file/set_without_load.*\):/*\1*/:' \
		-i testsuite/test-file-metadata.c || die

	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--enable-gvfs-metadata \
		$(use_enable introspection) \
		$(use_enable vala) \
		$(use_enable test valgrind)
}

src_test() {
	virtx emake check
}
