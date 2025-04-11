# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
PLOCALES="cs_CS de_DE es eu fr_FR id_ID ie it ko nb nl nn pt_BR ru_RU sv tr uk zh_CN zh_TW"

inherit gnome2-utils meson plocale python-r1 xdg-utils

DESCRIPTION="Simple and modern GTK eBook viewer"
HOMEPAGE="https://github.com/johnfactotum/foliate/"
SRC_URI="https://github.com/johnfactotum/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="handy spell"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	>=app-text/iso-codes-3.67
	dev-libs/gjs
	x11-libs/gtk+:3[introspection]
	x11-libs/pango[introspection]
	x11-libs/gdk-pixbuf:2[introspection]
	net-libs/webkit-gtk:4[introspection]
	handy? ( gui-libs/libhandy:=[introspection] )
	spell? ( app-text/gspell[introspection] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${MESON_DEPEND}
	sys-devel/gettext
"

src_prepare() {
	default

	plocale_find_changes "${S}"/po '' '.po'

	rm_po() {
		rm po/${1}.po
		sed -e "/^${1}/d" -i po/LINGUAS
	}

	plocale_for_each_disabled_locale rm_po
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
	gnome2_schemas_update
}
