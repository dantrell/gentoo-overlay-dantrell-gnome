# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"
PYTHON_COMPAT=( python{2_7,3_6,3_7,3_8} )
PYTHON_REQ_USE="xml"

inherit gnome2 meson multilib-minimal python-single-r1 vala

DESCRIPTION="An object-oriented framework for creating UPnP devs and control points"
HOMEPAGE="https://wiki.gnome.org/Projects/GUPnP"

LICENSE="LGPL-2"
SLOT="0/4"
KEYWORDS=""

IUSE="connman examples gtk-doc +introspection kernel_linux networkmanager"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	?? ( connman networkmanager )
"

# prefix: uuid dependency can be adapted to non-linux platforms
RDEPEND="${PYTHON_DEPS}
	>=net-libs/gssdp-1.1.3:0=[introspection?,${MULTILIB_USEDEP}]
	>=net-libs/libsoup-2.48.0:2.4[introspection?,${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.58:2[${MULTILIB_USEDEP}]
	>=dev-libs/libxml2-2.9.1-r4[${MULTILIB_USEDEP}]
	>=sys-apps/util-linux-2.24.1-r3[${MULTILIB_USEDEP}]
	introspection? (
			>=dev-libs/gobject-introspection-1.36:=
			$(vala_depend) )
	connman? ( >=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}] )
	networkmanager? ( >=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}] )
	!net-libs/gupnp-vala
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
	local backend=system
	use kernel_linux && backend=linux
	use connman && backend=connman
	use networkmanager && backend=network-manager

	local emesonargs=(
		-D context_manager="${backend}"
		$(meson_use introspection)
		$(meson_use introspection vapi)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use examples)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	ln -s "${ED}"/usr/bin/gupnp-binding-tool-1.2 "${ED}"/usr/bin/gupnp-binding-tool
	python_fix_shebang "${ED}"/usr/bin/gupnp-binding-tool-1.2
}
