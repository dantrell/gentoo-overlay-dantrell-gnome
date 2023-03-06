# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org meson xdg vala virtualx

DESCRIPTION="Building blocks for modern adaptive GNOME apps"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libhandy"
SRC_URI="https://gitlab.gnome.org/GNOME/libhandy/-/archive/${PV}/${P}.tar.bz2"

LICENSE="LGPL-2.1+"
SLOT="1"
KEYWORDS="*"

IUSE="examples glade gtk-doc +introspection test +vala"
REQUIRED_USE="
	gtk-doc? ( introspection )
	vala? ( introspection )
"

RESTRICT="!test? ( test )"

RDEPEND="
	!gui-libs/libhandy:1.0

	>=dev-libs/glib-2.44:2
	>=x11-libs/gtk+-3.24.1:3[introspection?]
	glade? ( dev-util/glade:3.10= )
	introspection? ( >=dev-libs/gobject-introspection-1.0:= )
"
DEPEND="${RDEPEND}
	x11-base/xorg-proto"
BDEPEND="
	dev-libs/libxml2:2
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	gtk-doc? ( >=dev-util/gi-docgen-2021.1
		app-text/docbook-xml-dtd:4.3 )
	vala? ( $(vala_depend) )
"

src_prepare() {
	# Work around -Werror=incompatible-pointer-types (GCC 11 default)
	sed -e '/Werror=incompatible-pointer-types/d' \
		-i meson.build || die

	default
	use vala && vala_setup
	xdg_environment_reset
}

src_configure() {
	local emesonargs=(
		-Dprofiling=false # -pg passing
		$(meson_feature introspection)
		$(meson_use vala vapi)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use test tests)
		$(meson_use examples)
		$(meson_feature glade glade_catalog)
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}
