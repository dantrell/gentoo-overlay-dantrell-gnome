# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson xdg

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="https://developer-old.gnome.org/libwnck/stable/ https://gitlab.gnome.org/GNOME/libwnck"

LICENSE="LGPL-2+"
SLOT="3"
KEYWORDS="*"

IUSE="gtk-doc +introspection startup-notification tools"

RDEPEND="
	x11-libs/cairo[X]
	>=dev-libs/glib-2.32:2
	>=x11-libs/gtk+-3.22:3[introspection?]
	startup-notification? ( >=x11-libs/startup-notification-0.4 )
	x11-libs/libX11
	x11-libs/libXres
	x11-libs/libXext
	introspection? ( >=dev-libs/gobject-introspection-0.6.14:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/meson-0.50.0
	>=dev-util/gtk-doc-am-1.9
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
"

src_prepare() {
	# Don't collide with SLOT=1 with USE=tools
	sed -e "s|executable(prog|executable(prog + '-3'|" -i libwnck/meson.build || die
	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		-Ddeprecation_flags=false
		$(meson_use tools install_tools)
		$(meson_feature startup-notification startup_notification)
		$(meson_feature introspection)
		$(meson_use gtk-doc gtk_doc)
	)
	meson_src_configure
}
