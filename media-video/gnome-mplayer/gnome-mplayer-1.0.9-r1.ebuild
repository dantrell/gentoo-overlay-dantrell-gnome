# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit flag-o-matic gnome2-utils xdg-utils

DESCRIPTION="A GTK+ interface to MPlayer"
HOMEPAGE="https://code.google.com/p/gnome-mplayer/"
SRC_URI="https://${PN}.googlecode.com/svn/packages/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="alsa +dbus +dconf gda gnome ipod libnotify pulseaudio"

COMMON_DEPEND=">=dev-libs/glib-2.30
	>=media-libs/gmtk-${PV}[dconf=]
	>=x11-libs/gtk+-3.2:3
	x11-libs/libX11
	x11-libs/libXScrnSaver
	alsa? ( media-libs/alsa-lib )
	dbus? ( >=dev-libs/dbus-glib-0.100 )
	gda? ( gnome-extra/libgda:5 )
	gnome? ( gnome-base/nautilus )
	ipod? ( >=media-libs/libgpod-0.7 )
	libnotify? ( >=x11-libs/libnotify-0.7 )
	pulseaudio? ( >=media-sound/pulseaudio-0.9.14 )"
RDEPEND="${COMMON_DEPEND}
	x11-themes/gnome-icon-theme-symbolic
	>=media-video/mplayer-1.0_rc4_p20100101[libass]"
DEPEND="${COMMON_DEPEND}
	sys-devel/gettext
	virtual/pkgconfig"

src_configure() {
	# Work around -fno-common (GCC 10 default)
	append-flags -fcommon

	# --disable-nemo only because it's untested and new feature in 1.0.9
	econf \
		--enable-gtk3 \
		$(use_enable gnome nautilus) \
		--disable-nemo \
		--with-gio \
		$(use_with dbus) \
		$(use_with gda libgda) \
		$(use_with alsa) \
		$(use_with pulseaudio) \
		$(use_with libnotify) \
		$(use_with ipod libgpod) \
		--without-libmusicbrainz3
}

src_install() {
	default
	rm -rf "${ED}"/usr/share/doc/${PN}
}

pkg_preinst() {
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}
