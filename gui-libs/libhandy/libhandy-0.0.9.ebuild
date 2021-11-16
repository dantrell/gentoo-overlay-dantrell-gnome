# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit meson multilib-minimal vala virtualx

DESCRIPTION="Building blocks for modern adaptive GNOME apps"
HOMEPAGE="https://source.puri.sm/Librem5/libhandy/"
SRC_URI="https://source.puri.sm/Librem5/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0.0/0"
KEYWORDS="*"

IUSE="examples glade gtk-doc +introspection test +vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.44:2[${MULTILIB_USEDEP}]
	glade? ( dev-util/glade:3.10= )
	gnome-base/gnome-desktop
	introspection? ( >=dev-libs/gobject-introspection-1.0:= )
	vala? ( $(vala_depend) )
	x11-libs/gtk+:3
"
DEPEND="${RDEPEND}
	dev-libs/libxml2:2
	gtk-doc? ( dev-util/gtk-doc )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

S="${WORKDIR}/${PN}-v${PV}"

src_prepare() {
	default

	# Work around -Werror=incompatible-pointer-types (GCC 11 default)
	sed -i meson.build \
		-e '/Werror=incompatible-pointer-types/d' || die

	use vala && vala_src_prepare
}

multilib_src_configure() {
	local emesonargs=(
		-Dprofiling=false
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

multilib_src_compile() {
	meson_src_compile
}

multilib_src_test() {
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
