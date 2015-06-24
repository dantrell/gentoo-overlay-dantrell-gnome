# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Compiler for the GObject type system"
HOMEPAGE="http://live.gnome.org/Vala"

LICENSE="LGPL-2.1"
SLOT="0.20"
KEYWORDS="*"
IUSE="test +vapigen"

RDEPEND="
	>=dev-libs/glib-2.18:2
	>=dev-libs/vala-common-${PV}"
DEPEND="${RDEPEND}
	!${CATEGORY}/${PN}:0
	dev-libs/libxslt
	sys-devel/flex
	virtual/pkgconfig
	virtual/yacc
	test? (
		dev-libs/dbus-glib
		>=dev-libs/glib-2.26:2 )"

src_configure() {
	DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README"
	gnome2_src_configure \
		--disable-unversioned \
		$(use_enable vapigen)
}
