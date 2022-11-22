# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2

DESCRIPTION="Compiler for the GObject type system"
HOMEPAGE="https://wiki.gnome.org/Projects/Vala https://gitlab.gnome.org/GNOME/vala"

LICENSE="LGPL-2.1"
SLOT="0.30"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.24:2
	>=dev-libs/vala-common-${PV}
"
DEPEND="${RDEPEND}
	test? (
		dev-libs/dbus-glib
		dev-libs/gobject-introspection:=
	)
"
BDEPEND="
	dev-libs/libxslt
	sys-devel/flex
	virtual/pkgconfig
	virtual/yacc
"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/vala/commit/06f4b599554773b5fbfe7cbab99eff8d94d2cb94
	eapply "${FILESDIR}"/${PN}-0.26.2-girparser-skip-source-position-elements.patch

	gnome2_src_prepare
}

src_configure() {
	# https://bugs.gentoo.org/483134
	export GIT_CEILING_DIRECTORIES="${WORKDIR}"

	gnome2_src_configure \
		--disable-unversioned
}
