# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala

DESCRIPTION="Clutter based world map renderer"
HOMEPAGE="https://wiki.gnome.org/Projects/libchamplain"

LICENSE="LGPL-2"
SLOT="0.12"
KEYWORDS="*"

IUSE="debug +gtk +introspection vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	dev-db/sqlite:3
	>=dev-libs/glib-2.16:2
	>=media-libs/clutter-1.12:1.0[introspection?]
	media-libs/cogl:=
	>=net-libs/libsoup-2.42:2.4
	>=x11-libs/cairo-1.4
	x11-libs/gtk+:3
	gtk? (
		x11-libs/gtk+:3[introspection?]
		media-libs/clutter-gtk:1.0 )
	introspection? ( dev-libs/gobject-introspection:= )
"
DEPEND="${RDEPEND}
	dev-build/gtk-doc-am
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	# Fix documentation slotability
	sed \
		-e "s/^DOC_MODULE.*/DOC_MODULE = ${PN}-${SLOT}/" \
		-i docs/reference/Makefile.{am,in} || die "sed (1) failed"
	sed \
		-e "s/^DOC_MODULE.*/DOC_MODULE = ${PN}-gtk-${SLOT}/" \
		-i docs/reference-gtk/Makefile.{am,in} || die "sed (2) failed"
	mv "${S}"/docs/reference/${PN}{,-${SLOT}}-docs.sgml || die "mv (1) failed"
	mv "${S}"/docs/reference-gtk/${PN}-gtk{,-${SLOT}}-docs.sgml || die "mv (2) failed"

	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	# Vala demos are only built, so just disable them
	gnome2_src_configure \
		--disable-memphis \
		--disable-static \
		--disable-vala-demos \
		$(use_enable debug) \
		$(use_enable gtk) \
		$(use_enable introspection) \
		$(use_enable vala)
}
