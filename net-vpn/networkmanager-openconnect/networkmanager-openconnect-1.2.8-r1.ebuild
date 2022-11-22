# Distributed under the terms of the GNU General Public License v2

EAPI="8"

GNOME_ORG_MODULE="NetworkManager-${PN##*-}"

inherit gnome2

DESCRIPTION="NetworkManager OpenConnect plugin"
HOMEPAGE="https://wiki.gnome.org/Projects/NetworkManager https://gitlab.gnome.org/GNOME/NetworkManager-openconnect"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk gtk4 +legacy"

DEPEND="
	>=net-misc/networkmanager-1.2:=
	>=dev-libs/glib-2.34:2
	>=dev-libs/dbus-glib-0.74
	dev-libs/libxml2:2
	>=net-vpn/openconnect-3.02:=
	gtk? (
		>=app-crypt/libsecret-0.18

		>=app-crypt/gcr-3.4:0=
		>=x11-libs/gtk+-3.12:3
	)
	gtk4? (
		>=gui-libs/gtk-4.0:4
	)
"
RDEPEND="
	${DEPEND}
	acct-group/nm-openconnect
	acct-user/nm-openconnect
"
BDEPEND="
	sys-devel/gettext
	dev-util/intltool
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		--disable-more-warnings \
		--disable-static \
		$(use_with legacy libnm-glib) \
		$(use_with gtk gnome) \
		$(use_with gtk authdlg) \
		$(use_with gtk4)
}

src_install() {
	gnome2_src_install

	# From AppStream (the /usr/share/appdata location is deprecated):
	# 	https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html#spec-component-location
	# 	https://bugs.gentoo.org/709450
	mv "${ED}"/usr/share/{appdata,metainfo} || die

	find "${ED}" -type f -name "*.la" -delete || die
}
