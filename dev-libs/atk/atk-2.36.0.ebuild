# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson multilib-minimal xdg

DESCRIPTION="GTK+ & GNOME Accessibility Toolkit"
HOMEPAGE="https://wiki.gnome.org/Accessibility"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk-doc +introspection"

RDEPEND="
	>=dev-libs/glib-2.38.0:2[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-1.54.0:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? (
		>=dev-util/gtk-doc-1.25
		app-text/docbook-xml-dtd:4.3 )
	virtual/pkgconfig
	>=sys-devel/gettext-0.19.8
"

multilib_src_configure() {
	local emesonargs=(
		-Ddocs=$(multilib_native_usex gtk-doc true false)
		-Dintrospection=$(multilib_native_usex introspection true false)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_test() {
	meson_src_test
}

multilib_src_install() {
	meson_src_install
}
