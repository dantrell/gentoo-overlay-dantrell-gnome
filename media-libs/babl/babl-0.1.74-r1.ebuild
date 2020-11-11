# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit meson

DESCRIPTION="A dynamic, any to any, pixel format conversion library"
HOMEPAGE="https://gegl.org/babl/"
SRC_URI="https://ftp.gimp.org/pub/${PN}/${PV:0:3}/${P}.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="*"

IUSE="introspection lcms cpu_flags_x86_avx2 cpu_flags_x86_f16c cpu_flags_x86_mmx cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse3 cpu_flags_x86_sse4_1"

BDEPEND="virtual/pkgconfig"
RDEPEND="
	introspection? ( >=dev-libs/gobject-introspection-1.32:= )
	lcms? ( >=media-libs/lcms-2.8:2 )
"
DEPEND="${RDEPEND}"

src_configure() {
	# Automagic rsvg support is just for website generation we do not call,
	#     so we don't need to fix it
	# w3m is used for dist target thus no issue for us that it is automagically
	#     detected
	local emesonargs=(
		-Dwith-docs=false
		$(meson_use introspection enable-gir)
		$(meson_use lcms with-lcms)
		$(meson_use cpu_flags_x86_avx2 enable-avx2)
		$(meson_use cpu_flags_x86_f16c enable-f16c)
		$(meson_use cpu_flags_x86_mmx enable-mmx)
		$(meson_use cpu_flags_x86_sse enable-sse)
		$(meson_use cpu_flags_x86_sse2 enable-sse2)
		$(meson_use cpu_flags_x86_sse3 enable-sse3)
		$(meson_use cpu_flags_x86_sse4_1 enable-sse4_1)
	)
	meson_src_configure
}
