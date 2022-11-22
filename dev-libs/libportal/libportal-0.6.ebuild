# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit meson vala virtualx

DESCRIPTION="Flatpak portal library"
HOMEPAGE="https://github.com/flatpak/libportal"
SRC_URI="https://github.com/flatpak/libportal/releases/download/${PV}/${P}.tar.xz"

LICENSE="LGPL-3"
SLOT="0/1-1-1-1" # soname of libportal{,-gtk3,-gtk4,-qt5}.so
KEYWORDS="*"

IUSE="gtk3 gtk4 gtk-doc +introspection qt5 test vala"
REQUIRED_USE="
	gtk-doc? ( introspection )
	vala? ( introspection )
"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.58:2
	introspection? ( dev-libs/gobject-introspection:= )
	gtk3? ( x11-libs/gtk+:3[introspection?] )
	gtk4? ( gui-libs/gtk:4[introspection?] )
	qt5? (
		dev-qt/qtcore:=
		dev-qt/qtgui:=
		dev-qt/qtx11extras:=
		dev-qt/qtwidgets:=
	)

	!sys-libs/libportal
"
DEPEND="${RDEPEND}
	qt5? (
		test? ( dev-qt/qttest:= )
	)
"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? ( dev-util/gi-docgen )
	qt5? (
		test? ( dev-qt/linguist-tools )
	)
	vala? ( $(vala_depend) )
"

src_prepare() {
	default
	use vala && vala_setup
}

src_configure() {
	local backends

	use gtk3 && backends+="gtk3,"
	use gtk4 && backends+="gtk4,"
	use qt5 && backends+="qt5,"

	local emesonargs=(
		-Dbackends=${backends%,}
		$(meson_use test portal-tests)
		$(meson_use introspection)
		$(meson_use vala vapi)
		$(meson_use gtk-doc docs)
		$(meson_use test tests)
	)
	meson_src_configure
}

src_test() {
	# Tests only exist for Qt5
	if use qt5; then
		virtx meson_src_test
	else
		# run meson_src_test to notice if tests are added
		meson_src_test
	fi
}

src_install() {
	meson_src_install

	if use gtk-doc; then
		mkdir -p "${ED}"/usr/share/gtk-doc/html/ || die
		mv "${ED}"/usr/share/doc/${PN}-1 "${ED}"/usr/share/gtk-doc/html/ || die
	fi
}
