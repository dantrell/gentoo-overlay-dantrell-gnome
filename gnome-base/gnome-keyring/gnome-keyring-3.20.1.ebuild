# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit fcaps flag-o-matic gnome2 pam versionator virtualx

DESCRIPTION="Password and keyring managing daemon"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeKeyring"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+caps pam selinux +ssh-agent"

RESTRICT="test"

# Replace gkd gpg-agent with pinentry[gnome-keyring] one, bug #547456
RDEPEND="
	>=app-crypt/gcr-3.5.3:0=[gtk]
	>=dev-libs/glib-2.38:2
	app-misc/ca-certificates
	>=dev-libs/libgcrypt-1.2.2:0=
	caps? ( sys-libs/libcap-ng )
	pam? ( sys-libs/pam )
	selinux? ( sec-policy/selinux-gnome )
	>=app-crypt/gnupg-2.0.28:=
"
DEPEND="${RDEPEND}
	>=app-eselect/eselect-pinentry-0.5
	app-text/docbook-xml-dtd:4.3
	dev-libs/libxslt
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
"
PDEPEND="app-crypt/pinentry[gnome-keyring]" #570512

src_prepare() {
	# Disable stupid CFLAGS with debug enabled
	sed -e 's/CFLAGS="$CFLAGS -g"//' \
		-e 's/CFLAGS="$CFLAGS -O0"//' \
		-i configure.ac configure || die

	gnome2_src_prepare
}

src_configure() {
	# Work around -fno-common (GCC 10 default)
	append-flags -fcommon

	gnome2_src_configure \
		$(use_with caps libcap-ng) \
		$(use_enable pam) \
		$(use_with pam pam-dir $(getpam_mod_dir)) \
		$(use_enable selinux) \
		$(use_enable ssh-agent) \
		--enable-doc
}

pkg_postinst() {
	# cap_ipc_lock only needed if building --with-libcap-ng
	# Never install as suid root, this breaks dbus activation, see bug #513870
	use caps && fcaps -m 755 cap_ipc_lock usr/bin/gnome-keyring-daemon
	gnome2_pkg_postinst

	if ! [[ $(eselect pinentry show | grep "pinentry-gnome3") ]] ; then
		ewarn "Please select pinentry-gnome3 as default pinentry provider:"
		ewarn " # eselect pinentry set pinentry-gnome3"
	fi
}
