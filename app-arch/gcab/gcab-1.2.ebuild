# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org meson vala xdg

DESCRIPTION="Library and tool for working with Microsoft Cabinet (CAB) files"
HOMEPAGE="https://wiki.gnome.org/msitools https://gitlab.gnome.org/GNOME/gcab"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="doc +introspection test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.44:2
	sys-libs/zlib
	introspection? ( >=dev-libs/gobject-introspection-0.9.4:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	doc? (
		>=dev-build/gtk-doc-am-1.14
	)
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
	$(vala_depend)
"

src_prepare() {
	default
	xdg_environment_reset
	vala_setup
}

src_configure() {
	local emesonargs=(
		-D docs=$(usex doc true false)
		-D introspection=$(usex introspection true false)
		-D tests=$(usex test true false)
	)
	meson_src_configure
}
