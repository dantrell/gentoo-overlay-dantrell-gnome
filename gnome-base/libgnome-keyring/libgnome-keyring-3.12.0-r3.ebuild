# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_10,3_11,3_12} )

inherit gnome2 python-any-r1 multilib-minimal

DESCRIPTION="Compatibility library for accessing secrets"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeKeyring"

LICENSE="LGPL-2+ GPL-2+" # tests are GPL-2
SLOT="0"
KEYWORDS="~*"

IUSE="debug +introspection test"

RDEPEND="
	>=dev-libs/glib-2.16.0:2[${MULTILIB_USEDEP}]
	>=dev-libs/libgcrypt-1.2.2:0=[${MULTILIB_USEDEP}]
	>=sys-apps/dbus-1[${MULTILIB_USEDEP}]
	>=gnome-base/gnome-keyring-3.1.92
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
"
DEPEND="${RDEPEND}
	dev-build/gtk-doc-am
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
	test? ( ${PYTHON_DEPS} )
"

src_prepare() {
	gnome2_src_prepare

	# FIXME: Remove silly CFLAGS, report upstream
	sed -e 's:CFLAGS="$CFLAGS -g:CFLAGS="$CFLAGS:' \
		-e 's:CFLAGS="$CFLAGS -O0:CFLAGS="$CFLAGS:' \
		-i configure.ac configure || die "sed failed"
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" gnome2_src_configure --disable-vala

	if multilib_is_native_abi; then
		ln -s "${S}"/docs/reference/gnome-keyring/html docs/reference/gnome-keyring/html || die
	fi
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_test() {
	dbus-launch emake check || die "tests failed"
}
