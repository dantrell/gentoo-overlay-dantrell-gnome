# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit gnome2 multilib-minimal toolchain-funcs meson

DESCRIPTION="Internationalized text layout and rendering library"
HOMEPAGE="http://www.pango.org/"

LICENSE="LGPL-2+ FTL"
SLOT="0"
KEYWORDS=""

IUSE="X +introspection test"

RDEPEND="
	>=media-libs/harfbuzz-1.2.3:=[glib(+),truetype(+),${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=media-libs/fontconfig-2.10.92:1.0=[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.5.0.1:2=[${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.12.14-r4:=[X?,${MULTILIB_USEDEP}]
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
	X? ( >=x11-proto/xproto-7.0.24[${MULTILIB_USEDEP}] )
	!<=sys-devel/autoconf-2.63:2.5
"

multilib_src_configure() {
	local emesonargs=(
		-Denable_doc=true
	)
	meson_src_configure

	if multilib_is_native_abi; then
		ln -s "${S}"/docs/html docs/html || die
	fi
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}
