# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools gnome2

DESCRIPTION="GNOME panel"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomePanel"

LICENSE="GPL-2+ FDL-1.1+ LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="eds elogind gtk-doc systemd"
REQUIRED_USE="
	^^ ( elogind systemd )
"

RDEPEND="
	gnome-base/gsettings-desktop-schemas
	>=gnome-base/gnome-desktop-2.91:3=
	>=x11-libs/gdk-pixbuf-2.26.0:2
	>=x11-libs/pango-1.15.4
	>=dev-libs/glib-2.45.3:2
	>=x11-libs/gtk+-3.22.0:3
	>=x11-libs/libwnck-3.4.6:3
	>=gnome-base/gnome-menus-3.7.90:3
	>=x11-libs/cairo-1[X]
	>=dev-libs/libgweather-3.5.1:2=
	>=x11-libs/libXrandr-1.3.0
	>=gnome-base/dconf-0.13.4
	sys-auth/polkit

	eds? ( >=gnome-extra/evolution-data-server-3.5.3:= )
	elogind? ( >=sys-auth/elogind-230:0= )
	systemd? ( >=sys-apps/systemd-230:0= )
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.4
	dev-util/itstool
	virtual/pkgconfig

	gtk-doc? ( dev-util/gtk-doc-am )
"

src_prepare() {
	if use elogind; then
		# From GNOME Without Systemd:
		# 	https://forums.gentoo.org/viewtopic-p-8335598.html#8335598
		eapply "${FILESDIR}"/${PN}-3.32.0-support-elogind.patch

		eautoreconf
	fi

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(use_enable eds) \
		$(use_enable gtk-doc)
}
