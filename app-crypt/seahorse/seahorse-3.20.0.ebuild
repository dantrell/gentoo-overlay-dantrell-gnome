# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_EAUTORECONF="yes"

inherit gnome2

DESCRIPTION="A GNOME application for managing encryption keys"
HOMEPAGE="https://wiki.gnome.org/Apps/Seahorse"

LICENSE="GPL-2+ FDL-1.1+"
SLOT="0"
KEYWORDS="*"

IUSE="debug ldap zeroconf"

COMMON_DEPEND="
	>=app-crypt/gcr-3.11.91:0=
	>=app-crypt/gnupg-2.0.12
	>=app-crypt/gpgme-1
	>=app-crypt/libsecret-0.16
	>=dev-libs/glib-2.10:2
	>=net-libs/libsoup-2.33.92:2.4
	net-misc/openssh
	>=x11-libs/gtk+-3.4:3
	x11-misc/shared-mime-info

	ldap? ( net-nds/openldap:= )
	zeroconf? ( >=net-dns/avahi-0.6:=[dbus] )
"
DEPEND="${COMMON_DEPEND}
	app-text/yelp-tools
	dev-util/gdbus-codegen
	>=dev-util/intltool-0.35
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"
# Need seahorse-plugins git snapshot
RDEPEND="${COMMON_DEPEND}
	!<app-crypt/seahorse-plugins-2.91.0_pre20110114
"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/seahorse/-/commit/31a9a6ffc10f9737e70d7f0051ff590ff284ad07
	eapply "${FILESDIR}"/${PN}-9999-accept-gnupg-2-2-x-as-supported-version.patch

	# Do not mess with CFLAGS with USE="debug"
	sed -e '/CFLAGS="$CFLAGS -g/d' \
		-e '/CFLAGS="$CFLAGS -O0/d' \
		-i configure.ac configure || die "sed 1 failed"

	gnome2_src_prepare
}

src_configure() {
	# bindir is needed due to bad macro expansion in desktop file, bug #508610
	gnome2_src_configure \
		--bindir=/usr/bin \
		--enable-pgp \
		--enable-ssh \
		--enable-pkcs11 \
		--enable-hkp \
		$(use_enable debug) \
		$(use_enable ldap) \
		$(use_enable zeroconf sharing) \
		VALAC=$(type -P true)
}
