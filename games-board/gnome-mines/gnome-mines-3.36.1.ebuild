# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org gnome2-utils meson vala xdg

DESCRIPTION="Clear hidden mines from a minefield"
HOMEPAGE="https://wiki.gnome.org/Apps/Mines"

LICENSE="GPL-3+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.40:2
	dev-libs/libgee:0.8
	>=x11-libs/gtk+-3.12:3
	dev-libs/libgnome-games-support:1=
	>=gnome-base/librsvg-2.32.0:2
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(vala_depend)
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	gnome-base/librsvg:2[vala]
"

PATCHES=(
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gnome-mines/-/commit/7214468e974422644b3702fcc0d56f66a788b982
	"${FILESDIR}"/${PN}-40.1-meson-drop-unused-argument-for-i18n-merge-file.patch
)
src_prepare() {
	xdg_src_prepare
	vala_src_prepare
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
