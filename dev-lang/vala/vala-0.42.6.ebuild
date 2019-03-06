# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome2

DESCRIPTION="Compiler for the GObject type system"
HOMEPAGE="https://wiki.gnome.org/Projects/Vala"

LICENSE="LGPL-2.1"
SLOT="0.42"
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

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/vala/commit/2b742fce82eb1326faaee3b2cc4ff993e701ef53
	# 	https://gitlab.gnome.org/GNOME/vala/commit/c63247759dca09d1a81dce6bc2e2992746d7c996
	eapply "${FILESDIR}"/${PN}-0.40.12-uncouple-valadoc.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	# https://bugs.gentoo.org/483134
	export GIT_CEILING_DIRECTORIES="${WORKDIR}"

	# weasyprint enables generation of PDF from HTML
	gnome2_src_configure \
		--disable-unversioned \
		VALAC=: \
		WEASYPRINT=:
}
