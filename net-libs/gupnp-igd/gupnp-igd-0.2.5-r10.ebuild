# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome.org multilib-minimal xdg

DESCRIPTION="Library to handle UPnP IGD port mapping for GUPnP"
HOMEPAGE="http://gupnp.org https://gitlab.gnome.org/GNOME/gupnp-igd"

LICENSE="LGPL-2.1+"
SLOT="0/1.2" # pkg-config file links in gupnp API, so some consumers of gupnp-igd need to be relinked for it
KEYWORDS="*"

IUSE="+introspection"

# The only existing test is broken
RESTRICT="test"

RDEPEND="
	>=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=net-libs/gssdp-1.2:0=[${MULTILIB_USEDEP}]
	>=net-libs/gupnp-1.2:0=[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.10:= )
"
DEPEND="${RDEPEND}
	>=dev-build/gtk-doc-am-1.10
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.2.5-gupnp-1.2.patch # needs eautoreconf, https://gitlab.gnome.org/GNOME/gupnp-igd/-/merge_requests/1
)

src_prepare() {
	xdg_src_prepare
	eautoreconf
}

multilib_src_configure() {
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
