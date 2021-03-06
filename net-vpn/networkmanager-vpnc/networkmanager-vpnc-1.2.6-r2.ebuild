# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME_ORG_MODULE="NetworkManager-${PN##*-}"

inherit gnome2

DESCRIPTION="NetworkManager VPNC plugin"
HOMEPAGE="https://wiki.gnome.org/Projects/NetworkManager"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk +legacy test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=net-misc/networkmanager-1.2.0:=
	>=dev-libs/dbus-glib-0.74
	>=dev-libs/glib-2.32:2
	>=net-vpn/vpnc-0.5.3_p550
	gtk? (
		>=x11-libs/gtk+-3.4:3
		legacy? ( >=gnome-extra/nm-applet-1.2.0[gtk] )
		!legacy? ( >=net-libs/libnma-1.2.0 )
		>=app-crypt/libsecret-0.18
	)
"
DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/intltool
	virtual/pkgconfig
"

src_prepare() {
	# Test will fail if the machine doesn't have a particular locale installed
	# https://bugzilla.gnome.org/show_bug.cgi?id=742708
	sed '/test_non_utf8_import (plugin/ d' \
		-i properties/tests/test-import-export.c || die "sed failed"

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-more-warnings \
		--disable-static \
		--with-dist-version=Gentoo \
		$(use_with gtk gnome) \
		$(use_with legacy libnm-glib)
}
