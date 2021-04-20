# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit meson xdg vala virtualx

MY_P="${PN}-v${PV}"

DESCRIPTION="Building blocks for modern adaptive GNOME apps"
HOMEPAGE="https://source.puri.sm/Librem5/libhandy/"
SRC_URI="https://source.puri.sm/Librem5/libhandy/-/archive/v${PV}/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1+"
SLOT="0.0/0"
KEYWORDS="~*"

IUSE="examples glade gtk-doc +introspection test +vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.44:2
	>=x11-libs/gtk+-3.24.1:3[introspection?]
	glade? ( dev-util/glade:3.10= )
	introspection? ( >=dev-libs/gobject-introspection-1.0:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	vala? ( $(vala_depend) )
	dev-libs/libxml2:2
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	gtk-doc? ( dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.3 )
"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/${PN}-0.0.13-glade3.36-compat{1,2}.patch
)

src_prepare() {
	use vala && vala_src_prepare
	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dprofiling=false # -pg passing
		-Dstatic=false
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

multilib_src_install() {
	meson_src_install

	# Ensure files are owned by libhandy
	if [[ -f /usr/$(get_libdir)/libhandy-0.0.so.0 ]]; then
		addwrite /usr/include/libhandy-0.0
		addwrite /usr/lib
		addwrite /usr/$(get_libdir)
		addwrite /usr/$(get_libdir)/girepository-1.0
		addwrite /usr/share/gir-1.0
		addwrite /usr/share/vala/vapi

		rm -f /usr/include/libhandy-0.0/handy.h
		rm -f /usr/include/libhandy-0.0/hdy-*.h
		rm -f /usr/lib*/girepository-1.0/Handy-0.0.typelib
		rm -f /usr/lib*/libhandy-0.0.so
		rm -f /usr/lib*/libhandy-0.0.so.0
		rm -f /usr/lib*/pkgconfig/libhandy-0.0.pc
		rm -f /usr/share/gir-1.0/Handy-0.0.gir
		rm -f /usr/share/vala/vapi/libhandy-0.0.deps
		rm -f /usr/share/vala/vapi/libhandy-0.0.vapi
	fi
}
