# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
GNOME2_LA_PUNT="yes"
VALA_USE_DEPEND="vapigen"

inherit vala gnome2 python-any-r1

DESCRIPTION="VNC viewer widget for GTK"
HOMEPAGE="https://wiki.gnome.org/Projects/gtk-vnc https://gitlab.gnome.org/GNOME/gtk-vnc"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="examples +introspection pulseaudio sasl vala"
REQUIRED_USE="
	vala? ( introspection )
"

# libview is used in examples/gvncviewer -- no need
# glib-2.30.1 needed to avoid linking failure due to .la files (bug #399129)
RDEPEND="
	>=dev-libs/glib-2.30.1:2
	>=dev-libs/libgcrypt-1.4.2:0=
	dev-libs/libgpg-error
	>=net-libs/gnutls-3.0:0=
	>=x11-libs/cairo-1.2
	x11-libs/libX11
	>=x11-libs/gtk+-3.0.0:3[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-0.9.4:= )
	pulseaudio? ( media-sound/pulseaudio )
	sasl? ( dev-libs/cyrus-sasl )
"
# Keymap databases code is generated with python3; configure picks up $PYTHON exported from python-any-r1_pkg_setup
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
	vala? (
		$(vala_depend)
		>=dev-libs/gobject-introspection-0.9.4:= )
"
# eautoreconf requires gnome-common

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local myconf=(
		$(use_with examples)
		$(use_enable introspection)
		$(use_with pulseaudio)
		$(use_with sasl)
		$(use_enable vala)
		--with-coroutine=gthread
		--without-libview
		--disable-static
		--with-gtk=3.0
	)

	gnome2_src_configure ${myconf[@]}
}
