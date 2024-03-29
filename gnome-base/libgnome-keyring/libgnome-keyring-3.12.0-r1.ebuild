# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
VALA_USE_DEPEND="vapigen"
VALA_MAX_API_VERSION="0.40"

inherit gnome2 vala multilib-minimal

DESCRIPTION="Compatibility library for accessing secrets"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeKeyring"

LICENSE="LGPL-2+ GPL-2+" # tests are GPL-2
SLOT="0"
KEYWORDS="*"

IUSE="debug +introspection vala"
REQUIRED_USE="vala? ( introspection )"

# tests need python2
RESTRICT="test"

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
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare

	# FIXME: Remove silly CFLAGS, report upstream
	sed -e 's:CFLAGS="$CFLAGS -g:CFLAGS="$CFLAGS:' \
		-e 's:CFLAGS="$CFLAGS -O0:CFLAGS="$CFLAGS:' \
		-i configure.ac configure || die "sed failed"
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(usex debug --enable-debug=yes ' ') \
		$(multilib_native_use_enable vala)

	if multilib_is_native_abi; then
		ln -s "${S}"/docs/reference/gnome-keyring/html docs/reference/gnome-keyring/html || die
	fi
}

multilib_src_install() {
	gnome2_src_install
}
