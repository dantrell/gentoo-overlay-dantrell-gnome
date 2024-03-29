# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org gnome2-utils meson udev xdg

DESCRIPTION="Bluetooth graphical utilities integrated with GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeBluetooth"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="2/13" # subslot = libgnome-bluetooth soname version
KEYWORDS="*"

IUSE="gtk-doc +introspection"

COMMON_DEPEND="
	>=x11-libs/gtk+-3.12:3[introspection?]
	media-libs/libcanberra[gtk3]
	>=x11-libs/libnotify-0.7.0
	virtual/libudev:=
	>=dev-libs/glib-2.38:2
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
"
RDEPEND="${COMMON_DEPEND}
	acct-group/plugdev
	virtual/udev
	>=net-wireless/bluez-5
"
DEPEND="${COMMON_DEPEND}
	!net-wireless/bluez-gnome
	dev-libs/libxml2:2
	dev-util/gdbus-codegen
	gtk-doc? ( >=dev-util/gtk-doc-1.9 )
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-Dicon_update=false
		$(meson_use gtk-doc gtk_doc)
		$(meson_use introspection)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	udev_dorules "${FILESDIR}"/61-${PN}.rules
}

pkg_postinst() {
	udev_reload
	gnome2_pkg_postinst
	if ! has_version 'sys-auth/consolekit[acl]' && ! has_version 'sys-auth/elogind[acl]' && ! has_version 'sys-apps/systemd[acl]' ; then
		elog "Don't forget to add yourself to the plugdev group "
		elog "if you want to be able to control bluetooth transmitter."
	fi
}

pkg_postrm() {
	udev_reload
}
