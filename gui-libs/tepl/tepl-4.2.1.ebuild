# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 virtualx

DESCRIPTION="GtkSourceView-based text editors and IDE helper library"
HOMEPAGE="https://gitlab.gnome.org/swilmet/tepl"

LICENSE="LGPL-2.1+"
SLOT="4"
KEYWORDS="*"

IUSE="+introspection"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.52:2
	>=x11-libs/gtk+-3.22:3[introspection?]
	>=x11-libs/gtksourceview-4.0:4[introspection?]
	>=gui-libs/amtk-5.0:5[introspection?]
	>=dev-libs/libxml2-2.5:2
	app-i18n/uchardet
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.6
	>=dev-build/gtk-doc-am-1.25
	virtual/pkgconfig
"

src_prepare() {
	# requires running gvfs-metadata
	sed -e 's:\(g_test_add_func.*/file/load_save_metadata_sync.*\):/*\1*/:' \
		-e 's:\(g_test_add_func.*/file/load_save_metadata_async.*\):/*\1*/:' \
		-e 's:\(g_test_add_func.*/file/set_without_load.*\):/*\1*/:' \
		-i testsuite/test-file-metadata.c || die

	gnome2_src_prepare
}

src_configure() {
	# valgrind checks not ran by default and require suppression files not in locations where they'd be installed by other packages
	gnome2_src_configure \
		--enable-gvfs-metadata \
		--disable-valgrind \
		$(use_enable introspection)
}

src_test() {
	virtx emake check
}
