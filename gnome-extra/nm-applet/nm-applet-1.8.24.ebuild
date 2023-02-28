# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
GNOME_ORG_MODULE="network-manager-applet"
GNOME2_EAUTORECONF="yes"

inherit gnome2

DESCRIPTION="GNOME applet for NetworkManager"
HOMEPAGE="https://wiki.gnome.org/Projects/NetworkManager"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="appindicator gcr gtk +introspection +modemmanager selinux teamd"

RDEPEND="
	>=app-crypt/libsecret-0.18
	dev-libs/glib:2=
	>=dev-libs/glib-2.38:2[dbus]
	>=dev-libs/dbus-glib-0.88
	dev-libs/libgudev:=
	>=sys-apps/dbus-1.4.1
	>=sys-auth/polkit-0.96-r1
	>=x11-libs/gtk+-3.10:3[introspection?]
	>=x11-libs/libnotify-0.7.0

	app-text/iso-codes
	>=net-misc/networkmanager-1.7:=[introspection?,modemmanager?,teamd?]
	net-misc/mobile-broadband-provider-info

	appindicator? (
		dev-libs/libayatana-appindicator
		>=dev-libs/libdbusmenu-16.04.0 )
	gtk? ( <net-misc/networkmanager-1.19:= )
	introspection? ( >=dev-libs/gobject-introspection-0.9.6:= )
	virtual/freedesktop-icon-theme
	gcr? ( >=app-crypt/gcr-3.14:0=[gtk] )
	modemmanager? ( net-misc/modemmanager )
	selinux? ( sys-libs/libselinux )
	teamd? ( >=dev-libs/jansson-2.7 )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.0
	>=sys-devel/gettext-0.18
	virtual/pkgconfig
"

PDEPEND="virtual/notification-daemon" #546134

PATCHES=(
	"${FILESDIR}"/${PN}-1.8.24-fix-bashisms.patch
)

src_prepare() {
	if has_version '<dev-libs/glib-2.44.0'; then
		eapply "${FILESDIR}"/${PN}-1.8.24-support-glib-2.42.patch
	fi

	gnome2_src_prepare
}

src_configure() {
	local myconf=(
		--with-appindicator=$(usex appindicator ayatana no)
		$(use_with gtk libnm-gtk)
		--without-libnma-gtk4
		--disable-lto
		--disable-ld-gc
		--disable-more-warnings
		--disable-static
		--localstatedir=/var
		$(use_enable introspection)
		$(use_with gcr)
		$(use_with modemmanager wwan)
		$(use_with selinux)
		$(use_with teamd team)
	)
	gnome2_src_configure "${myconf[@]}"
}
