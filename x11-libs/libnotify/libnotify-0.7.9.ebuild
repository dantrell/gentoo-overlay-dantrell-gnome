# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson multilib-minimal xdg-utils

DESCRIPTION="A library for sending desktop notifications"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libnotify"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~*"

IUSE="gtk-doc +introspection test"

RESTRICT="!test? ( test )"

RDEPEND="
	app-eselect/eselect-notify-send
	>=dev-libs/glib-2.26:2[${MULTILIB_USEDEP}]
	x11-libs/gdk-pixbuf:2[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-1.32:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-text/docbook-xsl-ns-stylesheets
	dev-libs/libxslt
	>=dev-libs/gobject-introspection-common-1.32
	virtual/man
	virtual/pkgconfig
	gtk-doc? ( dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.1.2 )
	test? ( x11-libs/gtk+:3[${MULTILIB_USEDEP}] )
"
PDEPEND="virtual/notification-daemon"

src_prepare() {
	default
	xdg_environment_reset
}

multilib_src_configure() {
	local emesonargs=(
		-Dtests="$(usex test true false)"
		-Dintrospection="$(multilib_native_usex introspection enabled disabled)"
		-Dman=true
		-Dgtk_doc=$(multilib_native_usex gtk-doc true false)
		-Ddocbook_docs=disabled
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install

	mv "${ED}"/usr/bin/{,libnotify-}notify-send || die #379941
}

pkg_postinst() {
	eselect notify-send update ifunset
}

pkg_postrm() {
	eselect notify-send update ifunset
}
