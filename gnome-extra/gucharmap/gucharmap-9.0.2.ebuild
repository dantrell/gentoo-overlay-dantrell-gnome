# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala versionator

DESCRIPTION="Unicode character map viewer and library"
HOMEPAGE="https://wiki.gnome.org/Apps/Gucharmap"

LICENSE="GPL-3"
SLOT="2.90"
KEYWORDS="*"

IUSE="debug +introspection test vala"
REQUIRED_USE="vala? ( introspection )"

COMMON_DEPEND="
	>=app-i18n/unicode-data-$(get_version_component_range 1-2)
	>=dev-libs/glib-2.32:2
	>=x11-libs/pango-1.2.1[introspection?]
	>=x11-libs/gtk+-3.4.0:3[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-0.9.0:= )
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-extra/gucharmap-3:0
"
DEPEND="${RDEPEND}
	app-text/yelp-tools
	dev-util/desktop-file-utils
	>=dev-util/gtk-doc-am-1
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
	test? (	app-text/docbook-xml-dtd:4.1.2 )
	vala? ( $(vala_depend) )
"

src_prepare() {
	# prevent file collisions with slot 0
	sed -e "s:GETTEXT_PACKAGE=gucharmap$:GETTEXT_PACKAGE=gucharmap-${SLOT}:" \
		-i configure.ac configure || die "sed configure.ac configure failed"

	# avoid autoreconf
	sed -e 's/-Wall //g' -i configure || die "sed failed"

	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--with-unicode-data=/usr/share/unicode-data \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable introspection) \
		$(use_enable vala)
}
