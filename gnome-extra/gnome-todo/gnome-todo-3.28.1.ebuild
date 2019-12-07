# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="Personal task manager"
HOMEPAGE="https://wiki.gnome.org/Apps/Todo"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="debug gtk-doc +introspection libecal2"

RDEPEND="
	>=dev-libs/glib-2.43.4:2
	>=dev-libs/libical-0.43:=
	>=dev-libs/libpeas-1.17
	!libecal2? ( >=gnome-extra/evolution-data-server-3.17.1:=[gtk] )
	libecal2? ( >=gnome-extra/evolution-data-server-3.33.2:=[gtk] )
	>=net-libs/gnome-online-accounts-3.2:=
	>=x11-libs/gtk+-3.22.0:3

	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
DEPEND="${RDEPEND}
	dev-libs/appstream-glib
	>=dev-util/gtk-doc-am-1.14
	>=dev-util/intltool-0.40.6
	sys-devel/gettext
	virtual/pkgconfig
"
src_prepare() {
	if use libecal2; then
		# From Fedora:
		# 	https://src.fedoraproject.org/rpms/gnome-todo/tree/f31
		eapply "${FILESDIR}"/${PN}-3.28.1-eds-port-to-libecal-2-0.patch
	elif has_version '>=dev-libs/glib-2.59.0'; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/gnome-todo/commit/6cdabc4dd0c6c804a093b94c269461ce376fed4f
		eapply "${FILESDIR}"/${PN}-9999-drop-the-autoptr-definition-for-esource.patch
	fi

	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D background_plugin=true
		-D dark_theme_plugin=true
		-D scheduled_panel_plugin=true
		-D score_plugin=true
		-D today_panel_plugin=true
		-D unscheduled_panel_plugin=true
		-D todo_txt_plugin=true
		-D todoist_plugin=true
		$(meson_use debug tracing)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use introspection)
	)
	meson_src_configure
}
