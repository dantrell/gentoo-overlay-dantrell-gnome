# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="GNOME default window manager"
HOMEPAGE="https://blogs.gnome.org/metacity/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="test xinerama"

# XXX: libgtop is automagic, hard-enabled instead
RDEPEND="
	>=x11-libs/gtk+-3.20.0:3
	>=x11-libs/pango-1.2[X]
	>=dev-libs/glib-2.44.0:2
	>=gnome-base/gsettings-desktop-schemas-3.3
	>=x11-libs/startup-notification-0.7
	>=x11-libs/libXcomposite-0.3
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXdamage
	x11-libs/libXcursor
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrandr
	x11-libs/libSM
	x11-libs/libICE
	media-libs/libcanberra[gtk3]
	gnome-base/libgtop:2=
	gnome-extra/zenity
	xinerama? ( x11-libs/libXinerama )
	!x11-misc/expocity
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.4
	dev-util/itstool
	virtual/pkgconfig
	test? ( app-text/docbook-xml-dtd:4.5 )
	xinerama? ( x11-base/xorg-proto )
"

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--enable-canberra \
		--enable-compositor \
		--enable-render \
		--enable-sm \
		--enable-startup-notification \
		$(use_enable xinerama)
}
