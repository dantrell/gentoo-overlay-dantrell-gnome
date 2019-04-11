# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Compiler for the GObject type system"
HOMEPAGE="https://wiki.gnome.org/Projects/Vala"

LICENSE="LGPL-2.1"
SLOT="0.44"
KEYWORDS="*"

IUSE="test"

RDEPEND="
	>=dev-libs/glib-2.40:2
	>=dev-libs/vala-common-${PV}
"
DEPEND="${RDEPEND}
	!${CATEGORY}/${PN}:0
	dev-libs/libxslt
	sys-devel/flex
	virtual/pkgconfig
	virtual/yacc
	>=media-gfx/graphviz-2.16
	test? (
		dev-libs/dbus-glib
		>=dev-libs/glib-2.40:2
		dev-libs/gobject-introspection:= )
"

src_configure() {
	# https://bugs.gentoo.org/483134
	export GIT_CEILING_DIRECTORIES="${WORKDIR}"

	# weasyprint enables generation of PDF from HTML
	gnome2_src_configure \
		--disable-unversioned \
		--disable-valadoc \
		VALAC=: \
		WEASYPRINT=:
}
