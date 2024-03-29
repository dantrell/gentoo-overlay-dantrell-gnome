# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit gnome.org meson vala xdg

DESCRIPTION="Clutter based world map renderer"
HOMEPAGE="https://wiki.gnome.org/Projects/libchamplain"

LICENSE="LGPL-2.1+"
SLOT="0.12"
KEYWORDS="*"

IUSE="+gtk gtk-doc +introspection vala"
REQUIRED_USE="
	vala? ( introspection )
	gtk-doc? ( gtk )
" # gtk-doc build gets disabled in meson if gtk widgetry is disabled (no separate libchamplain-gtk gtk-docs anymore)

RDEPEND="
	>=dev-libs/glib-2.38:2
	>=x11-libs/gtk+-3.0:3
	>=media-libs/clutter-1.24:1.0[introspection?]
	gtk? (
		x11-libs/gtk+:3[introspection?]
		media-libs/clutter-gtk:1.0 )
	>=x11-libs/cairo-1.4
	dev-db/sqlite:3
	>=net-libs/libsoup-2.42:2.4
	introspection? ( dev-libs/gobject-introspection:= )
	media-libs/cogl:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/meson-0.49.0
	virtual/pkgconfig
	gtk-doc? ( >=dev-util/gtk-doc-1.15 )
	vala? ( $(vala_depend) )
"

src_prepare() {
	xdg_src_prepare
	use vala && vala_src_prepare
	# Fix showing inside devhelp (gtkdocdir subdir and name of the module need to match)
	sed -i -e 's:package_name:package_string:' docs/reference/meson.build || die # https://gitlab.gnome.org/GNOME/libchamplain/-/merge_requests/7
}

src_configure() {
	local emesonargs=(
		-Dmemphis=false
		$(meson_use introspection)
		$(meson_use vala vapi)
		$(meson_use gtk widgetry)
		$(meson_use gtk-doc gtk_doc)
		-Ddemos=false # only built, not installed
	)
	meson_src_configure
}
