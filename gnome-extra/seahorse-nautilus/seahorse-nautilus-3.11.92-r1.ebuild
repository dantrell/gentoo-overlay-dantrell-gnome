# Distributed under the terms of the GNU General Public License v2

EAPI="8"
GNOME2_EAUTORECONF="yes"

inherit gnome2

DESCRIPTION="Nautilus extension for encrypting and decrypting files with GnuPG"
HOMEPAGE="https://gitlab.gnome.org/GNOME/seahorse-nautilus"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

DEPEND="
	>=app-crypt/gpgme-1.0.0
	>=app-crypt/gcr-3.4:0=[gtk]
	>=dev-libs/dbus-glib-0.35
	>=dev-libs/glib-2.28:2
	gnome-base/gnome-keyring
	>=gnome-base/nautilus-3
	x11-libs/gtk+:3
	>=x11-libs/libcryptui-3.9.90
	>=x11-libs/libnotify-0.3:=
	>=app-crypt/gnupg-1.4
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-util/intltool-0.35
	virtual/pkgconfig
"

src_prepare() {
	# Do not let configure mangle CFLAGS
	sed -e '/^[ \t]*CFLAGS="$CFLAGS \(-g\|-O0\)/d' -i configure.ac configure ||
		die "sed failed"

	# Fix icon location, https://gitlab.gnome.org/GNOME/seahorse-nautilus/-/issues/10
	sed -i 's/pixmaps\/seahorse-plugins\/48x48/pixmaps\/cryptui\/48x48/' \
		tool/seahorse-notification.c || die

	# Doesn't really need libgnome-keyring (from Fedora, fixed in
	# 'master')
	eapply "${FILESDIR}"/${PN}-3.11.92-remove-libgnome-keyring.patch # needs eautoreconf

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-gpg-check \
		--enable-libnotify
}
