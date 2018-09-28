# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="Personal task manager"
HOMEPAGE="https://wiki.gnome.org/Apps/Todo"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection"

RDEPEND="
	>=dev-libs/glib-2.43.4:2
	>=dev-libs/libical-0.43:=
	>=dev-libs/libpeas-1.17
	>=gnome-extra/evolution-data-server-3.17.1:=[gtk]
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

src_configure() {
	local emesonargs=(
		-D enable-background-plugin=true
		-D enable-dark-theme-plugin=true
		-D enable-scheduled-panel-plugin=true
		-D enable-score-plugin=true
		-D enable-today-panel-plugin=true
		-D enable-unscheduled-panel-plugin=true
		-D enable-todo-txt-plugin=true
		-D enable-todoist-plugin=true
		-D enable-gtk-doc=false
		-D enable-introspection=$(usex introspection true false)
	)
	meson_src_configure
}
