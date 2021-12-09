# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson xdg

DESCRIPTION="GLib helper library for geocoding services"
HOMEPAGE="https://gitlab.gnome.org/GNOME/geocode-glib"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk-doc +introspection test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.44:2
	>=dev-libs/json-glib-0.99.2[introspection?]
	>=net-libs/libsoup-2.42:2.4[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-0.6.3:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? (
		>=dev-util/gtk-doc-1.13
		app-text/docbook-xml-dtd:4.3 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.26.1-disable-installed-tests.patch
)

src_configure() {
	local emesonargs=(
		$(meson_use test enable-installed-tests) # Actual installation to live system is sedded out, but we need this for running them in src_test
		$(meson_use introspection enable-introspection)
		$(meson_use gtk-doc enable-gtk-doc)
	)
	meson_src_configure
}
