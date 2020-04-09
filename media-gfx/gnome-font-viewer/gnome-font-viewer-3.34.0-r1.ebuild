# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org meson xdg

DESCRIPTION="Font viewer utility for GNOME"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-font-viewer"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.35.1:2
	>=x11-libs/gtk+-3.20:3
	>=media-libs/harfbuzz-0.9.9
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	gnome-base/gnome-desktop:3=
"
DEPEND="${RDEPEND}
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gnome-font-viewer/commit/8089d86f30cb56fe2f720b6b4cfd9435d5cc3d92
	# 	https://gitlab.gnome.org/GNOME/gnome-font-viewer/commit/cbe443a8db3b7f09b2653d588c2ddd76d47fa496
	# 	https://gitlab.gnome.org/GNOME/gnome-font-viewer/commit/4d548988b61aad297219aa5ebfc68158b6d05b18
	# 	https://gitlab.gnome.org/GNOME/gnome-font-viewer/commit/9661683379806e2bad6a52ce6dde776a33f4f981 (CVE-2019-19308)
	# 	https://gitlab.gnome.org/GNOME/gnome-font-viewer/commit/519715d9b036563e467c813f69fbefff2042d89d
	"${FILESDIR}"/${PN}-3.34.1-update-the-minimum-required-glib-version.patch
	"${FILESDIR}"/${PN}-3.34.1-move-utility-to-get-font-name-to-sushi-font-loader.patch
	"${FILESDIR}"/${PN}-3.34.1-font-widget-use-sushi-get-font-name.patch
	"${FILESDIR}"/${PN}-3.34.1-fallback-to-basename-when-no-family-name-cve-2019-19308.patch
	"${FILESDIR}"/${PN}-3.34.1-font-view-use-basename-in-header-bar-when-no-family-name.patch
)
