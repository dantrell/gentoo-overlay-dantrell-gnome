# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_EAUTORECONF="yes"

inherit gnome2

DESCRIPTION="Playlist parsing library"
HOMEPAGE="https://developer.gnome.org/totem-pl-parser/stable/"

LICENSE="LGPL-2+"
SLOT="0/18"
KEYWORDS="*"

IUSE="archive crypt +introspection +quvi test"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/glib:2=
	>=dev-libs/glib-2.36:2
	quvi? ( >=media-libs/libquvi-0.9.1:0= )
	archive? ( >=app-arch/libarchive-3:0= )
	dev-libs/libxml2:2
	crypt? ( dev-libs/libgcrypt:0= )
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
	>=net-libs/libsoup-2.43:2.4
	dev-libs/gmime:2.6
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/gtk-doc-am-1.14
	>=sys-devel/gettext-0.17
	>=dev-util/intltool-0.35
	virtual/pkgconfig
	test? (
		gnome-base/gvfs[http]
		sys-apps/dbus )
"
# eautoreconf needs:
#	dev-libs/gobject-introspection-common
#	dev-build/autoconf-archive
BDEPEND="${BDEPEND}
	dev-libs/gobject-introspection-common
	dev-build/autoconf-archive
"

PATCHES=(
	# From Gentoo:
	# 	https://bugzilla.gnome.org/786231
	"${FILESDIR}"/${PN}-3.10.8-gmime-automagic.patch
)

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
	# uninstalled-tests is abused to switch from loading live FS helper
	# to in-build-tree helper, check on upgrades this is not having other
	# consequences, bug #630242
	gnome2_src_configure \
		--disable-static \
		--enable-gmime=2.6 \
		--enable-uninstalled-tests \
		$(use_enable quvi) \
		$(use_enable archive libarchive) \
		$(use_enable crypt libgcrypt) \
		$(use_enable introspection)
}

src_test() {
	# This is required as told by upstream in bgo#629542
	GVFS_DISABLE_FUSE=1 dbus-run-session emake check
}
