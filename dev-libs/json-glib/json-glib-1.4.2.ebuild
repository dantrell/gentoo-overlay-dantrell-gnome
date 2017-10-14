# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 multilib-minimal meson

DESCRIPTION="Library providing GLib serialization and deserialization for the JSON format"
HOMEPAGE="https://wiki.gnome.org/Projects/JsonGlib"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~*"

IUSE="debug +introspection"

RDEPEND="
	>=dev-libs/glib-2.37.6:2[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
"
DEPEND="${RDEPEND}
	~app-text/docbook-xml-dtd-4.1.2
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.20
	>=sys-devel/gettext-0.18
	virtual/pkgconfig[${MULTILIB_USEDEP}]
"

src_prepare() {
	# Do not touch CFLAGS with --enable-debug=yes
	sed -e 's/CFLAGS -g/CFLAGS/' -i "${S}"/configure || die
	gnome2_src_prepare
}

multilib_src_configure() {
	local emesonargs=(
		-Dintrospection=$(usex introspection true false)
		-Ddoc=true
	)
	meson_src_configure

	if multilib_is_native_abi; then
		ln -s "${S}"/doc/html doc/html || die
	fi
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}
