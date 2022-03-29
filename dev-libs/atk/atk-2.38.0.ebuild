# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org meson-multilib xdg

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
		$(meson_native_use_bool gtk-doc docs)
		$(meson_native_use_bool introspection)
	)
	meson_src_configure
}
