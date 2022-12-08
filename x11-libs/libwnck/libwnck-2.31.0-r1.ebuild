# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="https://developer-old.gnome.org/libwnck/stable/ https://gitlab.gnome.org/GNOME/libwnck"

LICENSE="LGPL-2+"
SLOT="1"
KEYWORDS="~*"

IUSE="+introspection startup-notification"

RDEPEND="
	>=x11-libs/gtk+-2.19.7:2[introspection?]
	>=dev-libs/glib-2.16:2
	x11-libs/libX11
	x11-libs/libXres
	x11-libs/libXext
	introspection? ( >=dev-libs/gobject-introspection-0.6.14:= )
	startup-notification? ( >=x11-libs/startup-notification-0.4 )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/gtk-doc-am
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
"
# eautoreconf needs
#	gnome-base/gnome-common

src_prepare() {
	# Regenerate pregenerated marshalers for <glib-2.31 compatibility
	rm -v libwnck/wnck-marshal.{c,h} || die "rm failed"

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		$(use_enable introspection) \
		$(use_enable startup-notification)
}
