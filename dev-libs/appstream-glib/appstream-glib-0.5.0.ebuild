# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit bash-completion-r1 gnome2

DESCRIPTION="Provides GObjects and helper methods to read and write AppStream metadata"
HOMEPAGE="https://people.freedesktop.org/~hughsient/appstream-glib/ https://github.com/hughsie/appstream-glib"
SRC_URI="https://people.freedesktop.org/~hughsient/${PN}/releases/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0/8" # soname version
KEYWORDS="*"

IUSE="+introspection nls"

RDEPEND="
	<app-arch/gcab-1.0
	app-arch/libarchive
	dev-db/sqlite:3
	>=dev-libs/glib-2.16.1:2
	dev-libs/libyaml
	>=media-libs/fontconfig-2.11
	>=media-libs/freetype-2.4:2
	>=net-libs/libsoup-2.24:2.4
	>=x11-libs/gdk-pixbuf-2.14:2[introspection?]
	x11-libs/gtk+:3
	x11-libs/pango
	introspection? ( >=dev-libs/gobject-introspection-0.9.8:= )
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.3
	dev-libs/libxslt
	>=dev-build/gtk-doc-am-1.9
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
"
# ${PN} superseeds appdata-tools, require dummy package until all ebuilds
# are migrated to appstream-glib
RDEPEND="${RDEPEND}
	!<dev-util/appdata-tools-0.1.8-r1
"
PDEPEND=">=dev-util/appdata-tools-0.1.8-r1"

src_configure() {
	gnome2_src_configure \
		--enable-builder \
		--disable-ostree \
		--disable-rpm \
		--disable-static \
		--enable-dep11 \
		--enable-man \
		$(use_enable nls) \
		$(use_enable introspection) \
		--with-bashcompletiondir="$(get_bashcompdir)"
}
