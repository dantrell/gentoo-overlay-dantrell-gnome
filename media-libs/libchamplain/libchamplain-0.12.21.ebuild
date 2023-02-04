# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org meson vala xdg

DESCRIPTION="Clutter based world map renderer"
HOMEPAGE="https://wiki.gnome.org/Projects/libchamplain"

LICENSE="LGPL-2.1+"
SLOT="0.12"
KEYWORDS=""

IUSE="+gtk gtk-doc +introspection vala"
REQUIRED_USE="
	vala? ( introspection )
	gtk-doc? ( gtk )
" # gtk-doc build gets disabled in meson if gtk widgetry is disabled (no separate libchamplain-gtk gtk-docs anymore)

RDEPEND="
	>=dev-libs/glib-2.68:2
	>=x11-libs/gtk+-3.0:3
	>=media-libs/clutter-1.24:1.0[introspection?]
	gtk? (
		x11-libs/gtk+:3[introspection?]
		media-libs/clutter-gtk:1.0
	)
	>=x11-libs/cairo-1.4
	dev-db/sqlite:3
	>=net-libs/libsoup-3:3.0
	introspection? ( dev-libs/gobject-introspection:= )
	media-libs/cogl:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? (
		>=dev-util/gtk-doc-1.15
		app-text/docbook-xml-dtd:4.1.2
	)
	vala? ( $(vala_depend) )
"

src_prepare() {
	default
	xdg_environment_reset
	use vala && vala_setup
}

src_configure() {
	local emesonargs=(
		-Dmemphis=false
		$(meson_use introspection)
		-Dlibsoup3=true
		$(meson_use vala vapi)
		$(meson_use gtk widgetry)
		$(meson_use gtk-doc gtk_doc)
		-Ddemos=false # only built, not installed
	)
	meson_src_configure
}
