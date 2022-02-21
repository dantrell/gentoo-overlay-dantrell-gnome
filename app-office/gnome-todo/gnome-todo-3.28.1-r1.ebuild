# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org gnome2-utils meson xdg

DESCRIPTION="Personal task manager"
HOMEPAGE="https://wiki.gnome.org/Apps/Todo"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="debug gtk-doc +introspection libecal2"

RDEPEND="
	>=dev-libs/glib-2.43.4:2
	>=x11-libs/gtk+-3.22.0:3[introspection?]
	>=net-libs/gnome-online-accounts-3.25.3:=
	>=dev-libs/libpeas-1.17
	!libecal2? ( >=gnome-extra/evolution-data-server-3.17.1:=[gtk] )
	libecal2? ( >=gnome-extra/evolution-data-server-3.33.2:=[gtk] )
	net-libs/rest:0.7
	dev-libs/json-glib
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
DEPEND="${RDEPEND}
	dev-libs/libxml2:2
	gtk-doc? ( dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.3 )
	>=sys-devel/gettext-0.19.8
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

	# From Gentoo:
	# 	https://bugs.gentoo.org/832136
	eapply "${FILESDIR}"/${PN}-fix-build-with-meson-0.61

	default
}

src_configure() {
	local emesonargs=(
		-Dbackground_plugin=true
		-Ddark_theme_plugin=true
		-Dscheduled_panel_plugin=true
		-Dscore_plugin=true
		-Dtoday_panel_plugin=true
		-Dunscheduled_panel_plugin=true
		-Dtodo_txt_plugin=true
		-Dtodoist_plugin=true
		$(meson_use debug tracing)
		$(meson_use gtk-doc gtk_doc)
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
