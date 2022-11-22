# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org meson vala xdg

DESCRIPTION="Library and tool for working with Microsoft Cabinet (CAB) files"
HOMEPAGE="https://wiki.gnome.org/msitools https://gitlab.gnome.org/GNOME/gcab"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~*"

IUSE="gtk-doc +introspection test vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.44:2
	sys-libs/zlib
	introspection? ( >=dev-libs/gobject-introspection-0.9.4:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/meson-0.50.0
	gtk-doc? (
		>=dev-util/gtk-doc-1.14
		app-text/docbook-xml-dtd:4.3
	)
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	default
	xdg_environment_reset
	use vala && vala_setup
}

src_configure() {
	local emesonargs=(
		$(meson_use gtk-doc docs)
		$(meson_use introspection)
		-Dnls=true
		$(meson_use vala vapi)
		$(meson_use test tests)
		-Dinstalled_tests=false
	)
	meson_src_configure
}
