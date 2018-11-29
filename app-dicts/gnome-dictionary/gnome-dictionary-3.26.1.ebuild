# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="Dictionary utility for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Dictionary"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="0/10" # subslot = suffix of libgdict-1.0.so
KEYWORDS="*"

IUSE="ipv6"

COMMON_DEPEND="
	>=dev-libs/glib-2.42:2[dbus]
	x11-libs/cairo:=
	>=x11-libs/gtk+-3.21.1:3
	x11-libs/pango
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gsettings-desktop-schemas
	!<gnome-extra/gnome-utils-3.4
"
# ${PN} was part of gnome-utils before 3.4
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xsl-stylesheets
	dev-libs/appstream-glib
	dev-libs/libxslt
	dev-util/itstool
	>=dev-util/meson-0.42.0
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-D build_man=true
		-D use_ipv6=$(usex ipv6 true false)
	)

	meson_src_configure
}
