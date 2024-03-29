# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_EAUTORECONF="yes"

inherit gnome2 systemd

DESCRIPTION="An integrated VNC server for GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/Vino"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="crypt debug gnome-keyring jpeg ssl +telepathy zeroconf +zlib"
# bug #394611; tight encoding requires zlib encoding
REQUIRED_USE="jpeg? ( zlib )"

# cairo used in vino-fb
# libSM and libICE used in eggsmclient-xsmp
RDEPEND="
	>=dev-libs/glib-2.26:2
	>=dev-libs/libgcrypt-1.1.90:0=
	>=x11-libs/gtk+-3:3

	x11-libs/cairo:=
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXtst
	x11-libs/pango[X]

	>=x11-libs/libnotify-0.7.0:=

	crypt? ( >=dev-libs/libgcrypt-1.1.90:0= )
	gnome-keyring? ( app-crypt/libsecret )
	jpeg? ( media-libs/libjpeg-turbo:0= )
	ssl? ( >=net-libs/gnutls-2.2.0:= )
	telepathy? (
		dev-libs/dbus-glib
		>=net-libs/telepathy-glib-0.18 )
	zeroconf? ( >=net-dns/avahi-0.6:=[dbus] )
	zlib? ( sys-libs/zlib:= )
"
DEPEND="${RDEPEND}
	app-crypt/libsecret
	>=dev-util/intltool-0.50
	gnome-base/gnome-common
	virtual/pkgconfig
"
# libsecret is always required at build time per bug 322763
# eautoreconf needs gnome-common

PATCHES=(
	"${FILESDIR}"/patches/ # Patches from master branch at 2020-02-15 state; needs autoreconf
	"${FILESDIR}"/CVE-2014-6053.patch
	"${FILESDIR}"/CVE-2018-7225.patch
	"${FILESDIR}"/CVE-2019-15681.patch
)

src_configure() {
	gnome2_src_configure \
		--enable-ipv6 \
		$(use_with crypt gcrypt) \
		$(usex debug --enable-debug=yes ' ') \
		$(use_with gnome-keyring secret) \
		$(use_with jpeg) \
		$(use_with ssl gnutls) \
		$(use_with telepathy) \
		$(use_with zeroconf avahi) \
		$(use_with zlib) \
		--with-systemduserunitdir="$(systemd_get_userunitdir)"
}
