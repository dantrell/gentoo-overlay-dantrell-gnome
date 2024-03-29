# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org gnome2-utils meson vala xdg

DESCRIPTION="Remove colored balls from the board by forming lines"
HOMEPAGE="https://wiki.gnome.org/Apps/Five%20or%20more"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-libs/libgee:0.8=
	>=dev-libs/glib-2.32:2
	>=x11-libs/gtk+-3.20:3
	dev-libs/libgnome-games-support:1=
	>=gnome-base/librsvg-2.32:2
"
DEPEND="${RDEPEND}"
# gnome-base/librsvg:2[vala] removed because it causes the following circular dependency (with gnome-base/librsvg):
#
# dev-lang/vala
#  media-gfx/graphviz
#   gnome-base/librsvg
#    dev-lang/vala
#
# Ref. https://github.com/dantrell/gentoo-project-gnome-without-systemd#known-issues
BDEPEND="
	$(vala_depend)
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	default
	vala_setup
	xdg_environment_reset
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
