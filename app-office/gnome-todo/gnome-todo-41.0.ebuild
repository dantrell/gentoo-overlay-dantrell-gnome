# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org gnome2-utils meson vala xdg

DESCRIPTION="Personal task manager"
HOMEPAGE="https://wiki.gnome.org/Apps/Todo"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="debug +introspection"

RDEPEND="
	>=dev-libs/glib-2.58.0:2
	>=gui-libs/gtk-3.92.0:4[introspection?]
	>=net-libs/gnome-online-accounts-3.25.3:=
	>=dev-libs/libpeas-1.17
	>=gnome-extra/evolution-data-server-3.33.2:=[gtk]
	net-libs/rest:0.7
	dev-libs/json-glib
	>=gui-libs/libadwaita-1.0.0:1=
	>=dev-libs/libportal-0.6[gtk4]
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(vala_depend)
	dev-libs/libxml2:2
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gnome-todo/-/issues/434
	"${FILESDIR}"/${PN}-41.0-build-fails-because-missing-libportal-gtk4-dependency.patch
)

src_prepare() {
	default
	vala_setup
	xdg_environment_reset
}

src_configure() {
	local emesonargs=(
		-Dunscheduled_panel_plugin=true
		-Dtodo_txt_plugin=true
		-Dtodoist_plugin=true
		$(meson_use debug tracing)
		$(meson_use introspection)
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
