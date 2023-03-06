# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit meson-multilib

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="https://www.cairographics.org/ https://gitlab.freedesktop.org/cairo/cairo"
SRC_URI="https://gitlab.freedesktop.org/cairo/cairo/-/archive/${PV}/cairo-${PV}.tar.bz2"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~*"

IUSE="X aqua debug +glib gtk-doc test"
RESTRICT="!test? ( test ) test" # Requires poppler-glib, which isn't available in multilib

RDEPEND="
	>=dev-libs/lzo-2.06-r1:2[${MULTILIB_USEDEP}]
	>=media-libs/fontconfig-2.10.92[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.5.0.1:2[png,${MULTILIB_USEDEP}]
	>=media-libs/libpng-1.6.10:0=[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}]
	>=x11-libs/pixman-0.36[${MULTILIB_USEDEP}]
	debug? ( sys-libs/binutils-libs:0=[${MULTILIB_USEDEP}] )
	glib? ( >=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}] )
	X? (
		>=x11-libs/libXrender-0.9.8[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2[${MULTILIB_USEDEP}]
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libxcb-1.9.1:=[${MULTILIB_USEDEP}]
	)"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-respect-fontconfig.patch

	# Upstream
	"${FILESDIR}"/${PN}-1.17.8-tee-Fix-cairo-wrapper-functions.patch
)

multilib_src_configure() {
	local emesonargs=(
		-Ddwrite=disabled
		-Dfontconfig=enabled
		-Dfreetype=enabled
		-Dpng=enabled
		$(meson_feature aqua quartz)
		$(meson_feature X tee)
		$(meson_feature X xcb)
		$(meson_feature X xlib)
		-Dxlib-xcb=disabled
		-Dxml=disabled
		-Dzlib=enabled

		$(meson_feature test tests)

		-Dgtk2-utils=disabled

		$(meson_feature glib)
		-Dspectre=disabled # only used for tests
		$(meson_feature debug symbol-lookup)

		$(meson_use gtk-doc gtk_doc)
	)

	meson_src_configure
}

multilib_src_install_all() {
	einstalldocs

	if use gtk-doc; then
		mkdir -p "${ED}"/usr/share/gtk-doc/cairo || die
		mv "${ED}"/usr/share/gtk-doc/{html/cairo,cairo/html} || die
		rmdir "${ED}"/usr/share/gtk-doc/html || die
	fi
}
