# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson vala virtualx xdg

DESCRIPTION="Text widget implementing syntax highlighting and other features"
HOMEPAGE="https://wiki.gnome.org/Projects/GtkSourceView"

LICENSE="LGPL-2.1+"
SLOT="4"
KEYWORDS="*"

IUSE="glade gtk-doc +introspection +vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=dev-libs/glib-2.48:2
	>=x11-libs/gtk+-3.24:3[introspection?]
	>=dev-libs/libxml2-2.6:2
	glade? ( >=dev-util/glade-3.9:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-1.42.0:= )
	>=dev-libs/fribidi-0.19.7
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? (
		>=dev-util/gtk-doc-1.25
		app-text/docbook-xml-dtd:4.3
	)
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use glade glade_catalog)
		-Dinstall_tests=false
		$(meson_use introspection gir)
		$(meson_use vala vapi)
		$(meson_use gtk-doc gtk_doc)
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}

src_install() {
	meson_src_install

	insinto /usr/share/${PN}-4.0/language-specs
	newins "${FILESDIR}"/gentoo.lang/4.6.lang gentoo.lang || die

	# Avoid conflict with gtksourceview:3.0 glade-catalog
	# TODO: glade doesn't actually show multiple GtkSourceView widget collections, so with both installed, can't really be sure which ones are used
	if use glade; then
		mv "${ED}"/usr/share/glade/catalogs/gtksourceview.xml "${ED}"/usr/share/glade/catalogs/gtksourceview-${SLOT}.xml || die
	fi
}
