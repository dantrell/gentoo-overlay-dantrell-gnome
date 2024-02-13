# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit xdg meson

DESCRIPTION="Provides GObjects and helper methods to read and write AppStream metadata"
HOMEPAGE="https://people.freedesktop.org/~hughsient/appstream-glib/ https://github.com/hughsie/appstream-glib"
SRC_URI="https://people.freedesktop.org/~hughsient/${PN}/releases/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0/8" # soname version
KEYWORDS="*"

IUSE="doc +introspection stemmer"

RDEPEND="
	>=dev-libs/glib-2.45.8:2
	sys-apps/util-linux
	app-arch/libarchive
	>=net-libs/libsoup-2.51.92:2.4
	>=dev-libs/json-glib-1.1.1
	>=x11-libs/gdk-pixbuf-2.31.5:2[introspection?]

	x11-libs/gtk+:3
	>=media-libs/freetype-2.4:2
	>=media-libs/fontconfig-2.11:1.0
	dev-libs/libyaml
	stemmer? ( dev-libs/snowball-stemmer:= )
	x11-libs/pango
	introspection? ( >=dev-libs/gobject-introspection-0.9.8:= )
"
DEPEND="${RDEPEND}"
# libxml2 required for glib-compile-resources
BDEPEND="
	dev-util/gperf

	dev-libs/libxml2:2
	app-text/docbook-xml-dtd:4.3
	dev-libs/libxslt
	doc? (
		>=dev-build/gtk-doc-am-1.9
	)
	>=sys-devel/gettext-0.19.7
"
# ${PN} superseeds appdata-tools
RDEPEND="${RDEPEND}
	!<dev-util/appdata-tools-0.1.8-r1
"

src_configure() {
	local emesonargs=(
		-D gtk-doc=$(usex doc true false)
		-D introspection=$(usex introspection true false)
		-D rpm=false
		-D stemmer=$(usex stemmer true false)
	)
	meson_src_configure
}
