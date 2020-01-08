# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 meson multilib-minimal vala

DESCRIPTION="A GObject-based API for handling resource discovery and announcement over SSDP"
HOMEPAGE="https://wiki.gnome.org/Projects/GUPnP"

LICENSE="LGPL-2"
SLOT="0/3"
KEYWORDS=""

IUSE="examples gtk gtk-doc +introspection"

RDEPEND="
	>=dev-libs/glib-2.42.2:2[${MULTILIB_USEDEP}]
	>=net-libs/libsoup-2.44.2:2.4[${MULTILIB_USEDEP},introspection?]
	gtk? ( >=x11-libs/gtk+-3.0:3 )
	introspection? (
		$(vala_depend)
		>=dev-libs/gobject-introspection-1.36:= )
	!<net-libs/gupnp-vala-0.10.3
"
DEPEND="${RDEPEND}
	gtk-doc? ( >=dev-util/gtk-doc-am-1.14 )
	sys-devel/gettext
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]
"

src_prepare() {
	use introspection && vala_src_prepare
	gnome2_src_prepare
}

multilib_src_configure() {
	local emesonargs=(
		$(meson_use examples)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use gtk sniffer)
		$(meson_use introspection)
		$(meson_use introspection vapi)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}
