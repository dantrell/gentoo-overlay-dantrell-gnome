# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Library providing a virtual terminal emulator widget"
HOMEPAGE="https://wiki.gnome.org/Apps/Terminal/VTE"

LICENSE="LGPL-2+"
SLOT="2.90"
KEYWORDS="*"

IUSE="debug glade +introspection"

PDEPEND=">=x11-libs/gnome-pty-helper-${PV}"
RDEPEND="
	>=dev-libs/glib-2.31.13:2
	>=x11-libs/gtk+-3.1.9:3[introspection?]
	>=x11-libs/pango-1.22.0

	sys-libs/ncurses:0=
	x11-libs/libX11
	x11-libs/libXft

	glade? ( >=dev-util/glade-3.9:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.0:= )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.13
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	# https://bugzilla.gnome.org/show_bug.cgi?id=663779
	eapply "${FILESDIR}"/${PN}-0.30.1-alt-meta.patch
	gnome2_src_prepare
}

src_configure() {
	local myconf=""

	if [[ ${CHOST} == *-interix* ]]; then
		myconf="${myconf} --disable-Bsymbolic"

		# interix stropts.h is empty...
		export ac_cv_header_stropts_h=no
	fi

	# Python bindings are via gobject-introspection
	# Ex: from gi.repository import Vte
	# Do not disable gnome-pty-helper, bug #401389
	gnome2_src_configure \
		--disable-deprecation \
		--disable-static \
		$(use_enable debug) \
		$(use_enable glade glade-catalogue) \
		$(use_enable introspection) \
		${myconf}
}

src_install() {
	gnome2_src_install
	rm -v "${ED}usr/libexec/gnome-pty-helper" || die
}
