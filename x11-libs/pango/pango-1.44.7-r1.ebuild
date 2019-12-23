# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit gnome2 meson multilib-minimal toolchain-funcs

DESCRIPTION="Internationalized text layout and rendering library"
HOMEPAGE="https://www.pango.org/"

LICENSE="LGPL-2+ FTL"
SLOT="0"
KEYWORDS="~*"

IUSE="X gtk-doc +introspection test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=media-libs/harfbuzz-1.4.2:=[glib(+),truetype(+),${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.59.2:2[${MULTILIB_USEDEP}]
	>=media-libs/fontconfig-2.11.91:1.0=[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.5.0.1:2=[${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.12.14-r4:=[X?,${MULTILIB_USEDEP}]
	>=dev-libs/fribidi-0.19.7[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
	X? (
		>=x11-libs/libXrender-0.9.8[${MULTILIB_USEDEP}]
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXft-2.3.1-r1[${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.20
	virtual/pkgconfig[${MULTILIB_USEDEP}]
	test? ( media-fonts/cantarell )
	X? ( x11-base/xorg-proto )
	!<=sys-devel/autoconf-2.63:2.5
"

src_prepare() {
	gnome2_src_prepare
}

multilib_src_configure() {
	tc-export CXX

	local emesonargs=(
		-Dgtk_doc="$(multilib_native_usex gtk-doc true false)"
		-Dintrospection="$(multilib_native_usex introspection true false)"
		-Dinstall-tests="$(multilib_native_usex test true false)"
		-Duse_fontconfig="$(multilib_native_usex X true false)"
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}