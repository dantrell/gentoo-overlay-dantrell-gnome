# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 readme.gentoo-r1 meson

DESCRIPTION="Screenshot utility for GNOME"
HOMEPAGE="https://git.gnome.org/browse/gnome-screenshot"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""

# libcanberra 0.26-r2 is needed for gtk+:3 fixes
COMMON_DEPEND="
	>=dev-libs/glib-2.35.1:2[dbus]
	>=media-libs/libcanberra-0.26-r2[gtk3]
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	>=x11-libs/gtk+-3.0.3:3
	x11-libs/libX11
	x11-libs/libXext
"
RDEPEND="${COMMON_DEPEND}
	>=gnome-base/gsettings-desktop-schemas-0.1.0
	!<gnome-extra/gnome-utils-3.4
"
# ${PN} was part of gnome-utils before 3.4
DEPEND="${COMMON_DEPEND}
	x11-proto/xextproto
	>=dev-util/intltool-0.50.2
	virtual/pkgconfig
"

DOC_CONTENTS="${P} saves screenshots in ~/Pictures/ and defaults to
	non-interactive mode when launched from a terminal. If you want to choose
	where to save the screenshot, run 'gnome-screenshot --interactive'"

src_install() {
	meson_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	gnome2_pkg_postinst
	gnome2_icon_cache_update
	gnome2_schemas_update
	readme.gentoo_print_elog
}

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}
