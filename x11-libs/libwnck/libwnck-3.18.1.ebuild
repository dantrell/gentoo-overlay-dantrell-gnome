# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools flag-o-matic gnome2

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="https://developer.gnome.org/libwnck/stable/"
SRC_URI="https://git.gnome.org/browse/${PN}/snapshot/${P}.tar.xz"

LICENSE="LGPL-2+"
SLOT="3"
KEYWORDS="*"

IUSE="+introspection startup-notification tools"

RDEPEND="
	x11-libs/cairo[X]
	>=x11-libs/gtk+-3.10:3[introspection?]
	>=dev-libs/glib-2.32:2
	x11-libs/libX11
	x11-libs/libXres
	x11-libs/libXext
	introspection? ( >=dev-libs/gobject-introspection-0.6.14:= )
	startup-notification? ( >=x11-libs/startup-notification-0.4 )
"
DEPEND="${RDEPEND}
	dev-util/gtk-doc
	dev-util/gtk-doc-am
	>=dev-util/intltool-0.40.6
	gnome-base/gnome-common
	sys-devel/gettext
	virtual/pkgconfig
"
# eautoreconf needs
#	gnome-base/gnome-common

src_prepare() {
	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	# Don't collide with SLOT=1
	gnome2_src_configure \
		--disable-static \
		$(use_enable introspection) \
		$(use_enable startup-notification) \
		$(use_enable tools) \
		--program-suffix=-${SLOT}
}
