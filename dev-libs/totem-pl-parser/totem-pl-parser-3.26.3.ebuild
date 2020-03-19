# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson xdg

DESCRIPTION="Playlist parsing library"
HOMEPAGE="https://developer.gnome.org/totem-pl-parser/stable/"

LICENSE="LGPL-2+"
SLOT="0/18"
KEYWORDS="*"

IUSE="archive crypt gtk-doc +introspection +quvi test"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/glib:2=
	>=dev-libs/glib-2.36:2
	quvi? ( >=media-libs/libquvi-0.9.1:0= )
	archive? ( >=app-arch/libarchive-3:0= )
	dev-libs/libxml2:2
	crypt? ( dev-libs/libgcrypt:0= )
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? (
		>=dev-util/gtk-doc-1.14
		app-text/docbook-xml-dtd:4.3 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	test? (
		gnome-base/gvfs[http]
		sys-apps/dbus )
"

src_prepare() {
	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		-Denable-quvi=$(usex quvi yes no)
		-Denable-libarchive=$(usex archive yes no)
		-Denable-libgcrypt=$(usex crypt yes no)
		$(meson_use gtk-doc enable-gtk-doc)
		$(meson_use introspection)
	)
	meson_src_configure
}

src_test() {
	# This is required as told by upstream in bgo#629542
	GVFS_DISABLE_FUSE=1 dbus-run-session meson test -C "${BUILD_DIR}"
}
