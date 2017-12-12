# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Compiler for the GObject type system"
HOMEPAGE="https://wiki.gnome.org/Projects/Vala"

LICENSE="LGPL-2.1"
SLOT="0.36"
KEYWORDS="*"

IUSE="test"

RDEPEND="
	>=dev-libs/glib-2.32:2
	>=dev-libs/vala-common-${PV}
"
DEPEND="${RDEPEND}
	!${CATEGORY}/${PN}:0
	dev-libs/libxslt
	sys-devel/flex
	virtual/pkgconfig
	virtual/yacc
	test? (
		dev-libs/dbus-glib
		>=dev-libs/glib-2.26:2 )
"

src_configure() {
	# weasyprint enables generation of PDF from HTML
	gnome2_src_configure \
		--disable-unversioned \
		VALAC=: \
		WEASYPRINT=:
}
