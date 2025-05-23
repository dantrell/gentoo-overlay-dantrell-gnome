# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome.org meson python-any-r1 udev xdg

DESCRIPTION="Bluetooth graphical utilities integrated with GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeBluetooth"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="2/13" # subslot = libgnome-bluetooth soname version
KEYWORDS="*"

IUSE="gtk-doc +introspection test"

RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/glib-2.44:2
	>=x11-libs/gtk+-3.12:3[introspection?]
	media-libs/libcanberra[gtk3]
	>=x11-libs/libnotify-0.7.0
	virtual/libudev:=
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
"
RDEPEND="${DEPEND}
	acct-group/plugdev
	virtual/udev
	>=net-wireless/bluez-5
"
BDEPEND="
	dev-libs/libxml2:2
	dev-util/gdbus-codegen
	gtk-doc? ( >=dev-util/gtk-doc-1.9 )
	virtual/pkgconfig
	test? (
		$(python_gen_any_dep '
			dev-python/python-dbusmock[${PYTHON_USEDEP}]
			dev-python/dbus-python[${PYTHON_USEDEP}]
		')
	)
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.34.5-meson-0.61-build.patch
)

python_check_deps() {
	if use test; then
		python_has_version "dev-python/python-dbusmock[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/dbus-python[${PYTHON_USEDEP}]"
	fi
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

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
	xdg_pkg_postinst
	if ! has_version 'sys-auth/consolekit[acl]' && ! has_version 'sys-auth/elogind[acl]' && ! has_version 'sys-apps/systemd[acl]' ; then
		elog "Don't forget to add yourself to the plugdev group "
		elog "if you want to be able to control bluetooth transmitter."
	fi
}

pkg_postrm() {
	udev_reload
}
