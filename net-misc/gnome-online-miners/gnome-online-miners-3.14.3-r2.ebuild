# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2

DESCRIPTION="Crawls through your online content"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeOnlineMiners"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="flickr"

# libgdata[gnome-online-accounts] needed for goa support
RDEPEND="
	>=app-misc/tracker-1:0=
	>=dev-libs/glib-2.35.1:2
	>=dev-libs/libgdata-0.15.2:0=[crypt,gnome-online-accounts]
	>=media-libs/grilo-0.2.6:0.2
	>=net-libs/gnome-online-accounts-3.13.3:=
	>=net-libs/libgfbgraph-0.2.2:0.2
	>=net-libs/libzapojit-0.0.2
	flickr? ( media-plugins/grilo-plugins:0.2[flickr] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		$(use_enable flickr) \
		--enable-facebook \
		--enable-google \
		--enable-media-server \
		--enable-owncloud \
		--enable-windows-live
}
