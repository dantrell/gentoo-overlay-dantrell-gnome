# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 meson vala versionator

DESCRIPTION="Unicode character map viewer and library"
HOMEPAGE="https://wiki.gnome.org/Apps/Gucharmap"
SRC_URI="https://gitlab.gnome.org/GNOME/${PN}/-/archive/${PV}/${P}.tar.bz2"

LICENSE="GPL-3+"
SLOT="2.90"
KEYWORDS="*"

IUSE="debug doc +introspection vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="mirror"

COMMON_DEPEND="
	=app-i18n/unicode-data-$(get_version_component_range 1-2)*
	>=dev-libs/glib-2.32:2
	>=x11-libs/pango-1.2.1[introspection?]
	>=x11-libs/gtk+-3.4.0:3[introspection?]
	media-libs/freetype:2
	introspection? ( >=dev-libs/gobject-introspection-0.9.0:= )
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-extra/gucharmap-3:0
"
DEPEND="${RDEPEND}
	dev-util/desktop-file-utils
	>=dev-util/gtk-doc-am-1
	>=dev-util/intltool-0.40
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D charmap=true
		$(meson_use debug dbg)
		$(meson_use doc docs)
		$(meson_use introspection gir)
		-D gtk3=true
		-D ucd_path=/usr/share/unicode-data
		$(meson_use vala vapi)
	)
	meson_src_configure
}
