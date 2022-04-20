# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit meson vala

DESCRIPTION="Flatpak portal library"
HOMEPAGE="https://github.com/flatpak/libportal"
SRC_URI="https://github.com/flatpak/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="*"

IUSE="gtk3 gtk4 gtk-doc +introspection qt5 test vala"
REQUIRED_USE="
	vala? ( introspection )
"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.58:2
	gtk3? ( x11-libs/gtk+:3[introspection?] )
	gtk4? ( >=gui-libs/gtk-4.4:4[introspection?] )
	introspection? ( dev-libs/gobject-introspection:= )
	qt5? ( dev-qt/qtcore:5 )

	!sys-libs/libportal
"
DEPEND="${RDEPEND}"
BDEPEND="
	vala? ( $(vala_depend) )
	virtual/pkgconfig
	gtk-doc? ( dev-util/gi-docgen )
"

src_prepare() {
	default
	use vala && vala_setup
}

src_configure() {
	local backends

	if use gtk3; then
		backends+="gtk3 "
	fi

	if use gtk4; then
		backends+="gtk4 "
	fi

	if use qt5; then
		backends+="qt5 "
	fi

	local emesonargs=(
		-Dbackends="$(_meson_env_array ${backends})"
		$(meson_use test portal-tests)
		$(meson_use introspection)
		$(meson_use vala vapi)
		$(meson_use gtk-doc docs)
		$(meson_use test tests)
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	if use gtk-doc; then
		mkdir -p "${ED}"/usr/share/gtk-doc/html/ || die
		mv "${ED}"/usr/share/doc/${PN}-1 "${ED}"/usr/share/gtk-doc/html/ || die
	fi
}
