# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org multilib-minimal xdg-utils

DESCRIPTION="Library to handle UPnP IGD port mapping for GUPnP"
HOMEPAGE="http://gupnp.org"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection"

# The only existing test is broken
RESTRICT="test"

RDEPEND="
	>=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=net-libs/gssdp-0.14.7:0/3[${MULTILIB_USEDEP}]
	>=net-libs/gupnp-0.20.10[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.10:= )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.10
	sys-devel/gettext
	virtual/pkgconfig
"

multilib_src_configure() {
	xdg_environment_reset

	# python is old-style bindings; use introspection and pygobject instead
	ECONF_SOURCE=${S} \
	econf \
		--disable-static \
		--disable-gtk-doc \
		--disable-python \
		$(multilib_native_use_enable introspection)

	if multilib_is_native_abi; then
		ln -s "${S}"/doc/html doc/html || die
	fi
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -name "*.la" -delete || die
}
