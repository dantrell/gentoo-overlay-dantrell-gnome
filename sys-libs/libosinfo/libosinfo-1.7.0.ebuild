# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 meson vala

DESCRIPTION="GObject library for managing information about real and virtual OSes"
HOMEPAGE="https://libosinfo.org/"
SRC_URI="https://releases.pagure.org/libosinfo/${P}.tar.xz"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk-doc +introspection +vala test"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

# Unsure about osinfo-db-tools rdep, but at least fedora does it too
RDEPEND="
	>=dev-libs/glib-2.44:2
	>=dev-libs/libxml2-2.6.0
	>=dev-libs/libxslt-1.0.0
	net-libs/libsoup:2.4
	sys-apps/hwids[pci,usb]
	sys-apps/osinfo-db-tools
	sys-apps/osinfo-db
	introspection? ( >=dev-libs/gobject-introspection-0.9.7:= )
"
# perl dep is for pod2man, and configure.ac checks for it too now
DEPEND="${RDEPEND}
	dev-lang/perl
	dev-libs/gobject-introspection-common
	gtk-doc? ( >=dev-util/gtk-doc-am-1.10 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	gnome2_src_prepare
	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use gtk-doc enable-gtk-doc)
		$(meson_feature introspection enable-introspection)
		$(meson_use test enable-tests)
		$(meson_feature vala enable-vala)
		-D with-pci-ids-path=/usr/share/misc/pci.ids
		-D with-usb-ids-path=/usr/share/misc/usb.ids
	)
	meson_src_configure
}
