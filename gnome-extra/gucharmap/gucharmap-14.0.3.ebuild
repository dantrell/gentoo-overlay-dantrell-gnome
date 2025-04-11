# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
VALA_MIN_API_VERSION="0.26"

inherit gnome2-utils meson python-any-r1 vala xdg

DESCRIPTION="Unicode character map viewer and library"
HOMEPAGE="https://wiki.gnome.org/Apps/Gucharmap https://gitlab.gnome.org/GNOME/gucharmap"
SRC_URI="https://gitlab.gnome.org/GNOME/${PN}/-/archive/${PV}/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="2.90"
KEYWORDS="*"

IUSE="+introspection gtk-doc vala"
REQUIRED_USE="vala? ( introspection )"

UNICODE_VERSION="14.0"

RDEPEND="media-libs/freetype:2
	>=dev-libs/glib-2.32:2
	>=x11-libs/gtk+-3.4.0:3[introspection?]
	>=dev-libs/libpcre2-10.21:=
	=app-i18n/unicode-data-${UNICODE_VERSION}*
	>=x11-libs/pango-1.42.4-r2[introspection?]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	app-text/docbook-xml-dtd:4.1.2
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	gtk-doc? ( >=dev-util/gtk-doc-1 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.0:= )
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-14.0.1-install-user-help.patch
	"${FILESDIR}"/${PN}-14.0.1-fix-file-conflicts.patch
)

src_prepare() {
	use vala && vala_src_prepare
	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dcharmap=true
		-Ddbg=false # in 14.0.1 all this does is pass -ggdb3
		$(meson_use gtk-doc docs)
		$(meson_use introspection gir)
		-Dgtk3=true
		-Ducd_path="${EPREFIX}/usr/share/unicode-data"
		$(meson_use vala vapi)
	)

	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
