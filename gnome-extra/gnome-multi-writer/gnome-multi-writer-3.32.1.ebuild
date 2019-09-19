# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="Write an ISO file to multiple USB devices at once"
HOMEPAGE="https://wiki.gnome.org/Apps/MultiWriter"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="introspection"

RDEPEND="
	>=x11-libs/gtk+-3.11.2
	introspection? ( >=dev-libs/gobject-introspection-0.9.8:= )
	>=dev-libs/libgusb-0.2.7:=
	sys-fs/udisks:2
	virtual/libgudev:=
	>=media-libs/libcanberra-0.10
	>=sys-auth/polkit-0.115
	>=dev-libs/glib-2.45.8
	x11-themes/gnome-icon-theme-extras
"
DEPEND="${RDEPEND}
	app-text/docbook-sgml-dtd:4.1
	app-text/docbook-sgml-utils
	dev-libs/appstream-glib
	>=dev-util/intltool-0.50
	sys-devel/gettext
"
