# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala

DESCRIPTION="Library and tool for working with Microsoft Cabinet (CAB) files"
HOMEPAGE="https://wiki.gnome.org/msitools https://gitlab.gnome.org/GNOME/gcab"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=dev-libs/glib-2.32:2
	sys-libs/zlib
	introspection? ( >=dev-libs/gobject-introspection-0.9.4:= )
"
DEPEND="${RDEPEND}
	>=dev-build/gtk-doc-am-1.14
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	gnome2_src_prepare
	use vala && vala_src_prepare
}

src_configure() {
	local myconf
	use vala || myconf="VAPIGEN=no"
	gnome2_src_configure \
		--disable-static \
		$(use_enable introspection) \
		${myconf}
}
