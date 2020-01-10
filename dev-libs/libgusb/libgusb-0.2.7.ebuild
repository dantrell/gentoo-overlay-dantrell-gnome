# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 multilib-minimal vala

DESCRIPTION="GObject wrapper for libusb"
HOMEPAGE="https://github.com/hughsie/libgusb"
SRC_URI="https://people.freedesktop.org/~hughsient/releases/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection static-libs vala"
REQUIRED_USE="vala? ( introspection )"

# Tests try to access usb devices in /dev
RESTRICT="test"

RDEPEND="
	>=dev-libs/glib-2.38.0:2[${MULTILIB_USEDEP}]
	virtual/libusb:1[udev,${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-1.29:= )
"
DEPEND="${RDEPEND}
	dev-libs/libxslt
	dev-util/gtk-doc-am
	virtual/pkgconfig[${MULTILIB_USEDEP}]
	vala? ( $(vala_depend) )
"

src_prepare() {
	gnome2_src_prepare
	use vala && vala_src_prepare
}

multilib_src_configure() {
	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		$(multilib_native_use_enable introspection) \
		$(use_enable static-libs static) \
		$(multilib_native_use_enable vala)

	if multilib_is_native_abi; then
		ln -s "${S}"/docs/api/html docs/api/html || die
	fi
}

multilib_src_install() {
	gnome2_src_install
}
