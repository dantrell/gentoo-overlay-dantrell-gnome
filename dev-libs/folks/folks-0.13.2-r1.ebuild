# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit gnome.org gnome2-utils meson vala xdg

DESCRIPTION="Library for aggregating people from multiple sources"
HOMEPAGE="https://wiki.gnome.org/Projects/Folks https://gitlab.gnome.org/GNOME/folks"

LICENSE="LGPL-2.1+"
SLOT="0/25" # subslot = libfolks soname version
KEYWORDS="*"

IUSE="bluetooth eds telepathy tracker utils"
REQUIRED_USE="bluetooth? ( eds )"

DEPEND="
	>=dev-libs/glib-2.44:2
	>=dev-libs/libgee-0.10:0.8[introspection]
	>=dev-libs/gobject-introspection-1.54:=
	telepathy? (
		>=net-libs/telepathy-glib-0.19.9
		dev-libs/dbus-glib
	)
	tracker? ( app-misc/tracker:0= )
	eds? ( >=gnome-extra/evolution-data-server-3.33.2:= )
	dev-libs/libxml2:2
	utils? ( sys-libs/readline:0= )
"
# telepathy-mission-control needed at runtime; it is used by the telepathy
# backend via telepathy-glib's AccountManager binding.
RDEPEND="${DEPEND}
	bluetooth? ( >=net-wireless/bluez-5[obex] )
	telepathy? ( net-im/telepathy-mission-control )
"
BDEPEND="
	>=dev-build/meson-0.51
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	bluetooth? ( dev-python/python-dbusmock )
	$(vala_depend)
	telepathy? ( net-libs/telepathy-glib[vala] )
	eds? ( gnome-extra/evolution-data-server[vala] )
"

src_prepare() {
	vala_src_prepare
	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use bluetooth bluez_backend)
		$(meson_use eds eds_backend)
		$(meson_use eds ofono_backend)
		$(meson_use telepathy telepathy_backend)
		$(meson_use tracker tracker_backend)
		-Dzeitgeist=false # last rited package
		-Dimport_tool=true
		$(meson_use utils inspect_tool)
		-Dinstalled_tests=false
		-Ddocs=false # Needs find_program sedding to specific version; only dev docs, don't bother
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
