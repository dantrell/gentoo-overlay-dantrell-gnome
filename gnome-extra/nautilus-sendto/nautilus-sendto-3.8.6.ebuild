# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="A nautilus extension for sending files to locations"
HOMEPAGE="https://git.gnome.org/browse/nautilus-sendto/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE=""

RDEPEND="
	>=x11-libs/gtk+-2.90.3:3
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
"

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postinst() {
	gnome2_icon_cache_update
	gnome2_schemas_update

	if ! has_version "gnome-base/nautilus[sendto]"; then
		einfo "Note that ${CATEGORY}/${PN} is meant to be used as a helper by gnome-base/nautilus[sendto]"
	fi
}
