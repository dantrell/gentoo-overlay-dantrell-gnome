# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools bash-completion-r1 gnome2

DESCRIPTION="Provides GObjects and helper methods to read and write AppStream metadata"
HOMEPAGE="https://people.freedesktop.org/~hughsient/appstream-glib/ https://github.com/hughsie/appstream-glib"
SRC_URI="https://people.freedesktop.org/~hughsient/${PN}/releases/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0/8" # soname version
KEYWORDS="*"

IUSE="+introspection nls stemmer"

RDEPEND="
	>=app-arch/gcab-1.0
	app-arch/libarchive
	dev-db/sqlite:3
	>=dev-libs/glib-2.45.8:2
	>=dev-libs/json-glib-1.1.1
	dev-libs/libyaml
	>=media-libs/fontconfig-2.11:1.0
	>=media-libs/freetype-2.4:2
	>=net-libs/libsoup-2.51.92:2.4
	sys-apps/util-linux
	>=x11-libs/gdk-pixbuf-2.31.5:2[introspection?]
	x11-libs/gtk+:3
	x11-libs/pango
	introspection? ( >=dev-libs/gobject-introspection-0.9.8:= )
	stemmer? ( dev-libs/snowball-stemmer:= )
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.3
	dev-libs/libxslt
	>=dev-build/gtk-doc-am-1.9
	>=sys-devel/gettext-0.19.7
	dev-util/gperf
"
# ${PN} superseeds appdata-tools, require dummy package until all ebuilds
# are migrated to appstream-glib
RDEPEND="${RDEPEND}
	!<dev-util/appdata-tools-0.1.8-r1
"

src_prepare() {
	# From AppStream-Glib:
	# 	https://github.com/hughsie/appstream-glib/commit/f7a064e4509d7f24d57d39a71ecde90292de9a3b
	eapply "${FILESDIR}"/${PN}-0.5.19-fix-compile-with-gcab-v1-0.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--enable-builder \
		--enable-firmware \
		--enable-fonts \
		--disable-rpm \
		--disable-static \
		--enable-dep11 \
		--enable-man \
		$(use_enable nls) \
		$(use_enable introspection) \
		$(use_enable stemmer) \
		--with-bashcompletiondir="$(get_bashcompdir)"
}
