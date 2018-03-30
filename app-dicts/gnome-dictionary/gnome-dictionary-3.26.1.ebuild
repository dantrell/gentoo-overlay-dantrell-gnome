# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="Dictionary utility for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Dictionary"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="0/10" # subslot = suffix of libgdict-1.0.so
KEYWORDS="*"

IUSE="debug +introspection ipv6"

COMMON_DEPEND="
	>=dev-libs/glib-2.42:2[dbus]
	x11-libs/cairo:=
	>=x11-libs/gtk+-3.21.1:3
	x11-libs/pango
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gsettings-desktop-schemas
	!<gnome-extra/gnome-utils-3.4
"
# ${PN} was part of gnome-utils before 3.4
DEPEND="${COMMON_DEPEND}
	>=dev-util/gtk-doc-am-1.15
	>=dev-util/intltool-0.40
	dev-util/itstool
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-Denable-ipv6=$(usex ipv6 true false)
	)

	meson_src_configure
}
