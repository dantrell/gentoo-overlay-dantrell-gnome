# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org gnome2-utils meson vala xdg

DESCRIPTION="Remove colored balls from the board by forming lines"
HOMEPAGE="https://wiki.gnome.org/Apps/Five%20or%20more"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.32:2
	>=x11-libs/gtk+-3.20:3
	dev-libs/libgnome-games-support:=
	>=gnome-base/librsvg-2.32:2
"
DEPEND="${RDEPEND}
	$(vala_depend)
	dev-libs/appstream-glib
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	vala_src_prepare
	xdg_src_prepare
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
