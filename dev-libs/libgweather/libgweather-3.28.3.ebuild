# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala meson

DESCRIPTION="Library to access weather information from online services"
HOMEPAGE="https://wiki.gnome.org/Projects/LibGWeather"

LICENSE="GPL-2+"
SLOT="2/3-15" # subslot = 3-(libgweather-3 soname suffix)
KEYWORDS="*"

IUSE="doc glade +introspection vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=dev-libs/glib-2.35.1:2
	>=x11-libs/gtk+-3.13.5:3[introspection?]
	>=net-libs/libsoup-2.44:2.4
	>=dev-libs/libxml2-2.6.0:2
	sci-geosciences/geocode-glib
	>=sys-libs/timezone-data-2010k

	glade? ( >=dev-util/glade-3.16:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.11
		app-text/docbook-xml-dtd:4.3 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D glade_catalog=$(usex glade true false)
		-D enable_vala=$(usex vala true false)
		-D gtk_doc=$(usex doc true false)
	)
	meson_src_configure
}
