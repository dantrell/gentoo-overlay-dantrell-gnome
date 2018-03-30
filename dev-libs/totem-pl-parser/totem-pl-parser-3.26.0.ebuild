# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="Playlist parsing library"
HOMEPAGE="https://developer.gnome.org/totem-pl-parser/stable/"

LICENSE="LGPL-2+"
SLOT="0/18"
KEYWORDS="*"

IUSE="archive crypt +introspection +quvi test"

RDEPEND="
	>=dev-libs/glib-2.31:2
	dev-libs/gmime:2.6
	>=net-libs/libsoup-2.43:2.4
	archive? ( >=app-arch/libarchive-3 )
	crypt? ( dev-libs/libgcrypt:0= )
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
	quvi? ( >=media-libs/libquvi-0.9.1:0= )
"
DEPEND="${RDEPEND}
	!<media-video/totem-2.21
	dev-libs/gobject-introspection-common
	>=dev-util/intltool-0.35
	>=dev-util/gtk-doc-1.14
	sys-devel/autoconf-archive
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	test? (
		gnome-base/gvfs[http]
		sys-apps/dbus )
"

src_prepare() {
	# Disable tests requiring network access, bug #346127
	# 3rd test fails on upgrade, not once installed
	sed -e 's:\(g_test_add_func.*/parser/resolution.*\):/*\1*/:' \
		-e 's:\(g_test_add_func.*/parser/parsing/itms_link.*\):/*\1*/:' \
		-e 's:\(g_test_add_func.*/parser/parsability.*\):/*\1/:'\
		-i plparse/tests/parser.c || die "sed failed"

	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D enable-quvi=$(usex quvi yes no)
		-D enable-libarchive=$(usex archive yes no)
		-D enable-libgcrypt=$(usex crypt yes no)
		-D enable-gtk-doc=true
	)
	meson_src_configure
}
