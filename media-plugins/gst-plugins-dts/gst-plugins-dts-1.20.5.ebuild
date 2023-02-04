# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="DTS audio decoder plugin for Gstreamer"
KEYWORDS="*"

IUSE="+orc"

RDEPEND="
	>=media-libs/libdca-0.0.5-r3[${MULTILIB_USEDEP}]
	orc? ( >=dev-lang/orc-0.4.17[${MULTILIB_USEDEP}] )
"
DEPEND="${RDEPEND}"

multilib_src_configure() {
	local emesonargs=(
	    -Dgpl=enabled
	)

	gstreamer_multilib_src_configure
}
