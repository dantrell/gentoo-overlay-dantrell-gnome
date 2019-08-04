# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit meson multilib-minimal vala

DESCRIPTION="A library full of GTK+ widgets for mobile phones"
HOMEPAGE="https://source.puri.sm/Librem5/libhandy"
SRC_URI="https://source.puri.sm/Librem5/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="glade gtk-doc +introspection +vala test"

RDEPEND="
	>=dev-libs/glib-2.44:2[${MULTILIB_USEDEP}]
	dev-util/glade
	gnome-base/gnome-desktop
	introspection? ( >=dev-libs/gobject-introspection-1.0:= )
	vala? ( $(vala_depend) )
	x11-libs/gtk+:3
"
DEPEND="${RDEPEND}
	dev-libs/libxml2:2
	gtk-doc? ( dev-util/gtk-doc )
	sys-devel/gettext
	virtual/pkgconfig[${MULTILIB_USEDEP}]
"

S="${WORKDIR}/${PN}-v${PV}"

src_prepare() {
	default

	use vala && vala_src_prepare
}

multilib_src_configure() {
	local emesonargs=(
		-D profiling=false
		-D static=false
		$(meson_feature introspection)
		$(meson_use vala vapi)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use test test)
		-D examples=false
		$(meson_feature glade glade_catalog)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}
