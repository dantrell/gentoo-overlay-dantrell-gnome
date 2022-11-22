# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2

DESCRIPTION="Compiler for the GObject type system"
HOMEPAGE="https://wiki.gnome.org/Projects/Vala https://gitlab.gnome.org/GNOME/vala"

LICENSE="LGPL-2.1+"
SLOT="0.52"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.48:2
	>=dev-libs/vala-common-${PV}
	!<net-libs/libsoup-2.66.2[vala]
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

src_install() {
	default
	find "${D}" -name "*.la" -delete || die
}
