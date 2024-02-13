# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala

DESCRIPTION="GObject library for managing information about real and virtual OSes"
HOMEPAGE="https://libosinfo.org/"
SRC_URI="https://releases.pagure.org/libosinfo/${P}.tar.gz"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection +vala test"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

# Unsure about osinfo-db-tools rdep, but at least fedora does it too
RDEPEND="
	>=dev-libs/glib-2.38.0:2
	net-libs/libsoup:2.4
	>=dev-libs/libxml2-2.6.0
	>=dev-libs/libxslt-1.0.0
	sys-apps/hwdata
	sys-apps/osinfo-db-tools
	sys-apps/osinfo-db
	introspection? ( >=dev-libs/gobject-introspection-0.9.7:= )
"
DEPEND="${RDEPEND}"
# perl dep is for pod2man for automagic manpage building
BDEPEND="
	dev-lang/perl
	dev-libs/gobject-introspection-common
	>=dev-build/gtk-doc-am-1.10
	>=dev-util/intltool-0.40.0
	virtual/pkgconfig
	test? (
		>=sys-apps/osinfo-db-20180612
	)
	vala? ( $(vala_depend) )
"

src_prepare() {
	gnome2_src_prepare
	use vala && vala_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		$(use_enable introspection) \
		$(use_enable test tests) \
		$(use_enable vala) \
		--with-pci-ids-path=/usr/share/hwdata/pci.ids \
		--with-usb-ids-path=/usr/share/hwdata/usb.ids \
		--disable-coverage
}
