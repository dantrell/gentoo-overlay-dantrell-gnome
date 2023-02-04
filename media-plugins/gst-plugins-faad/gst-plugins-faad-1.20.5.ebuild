# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="AAC audio decoder plugin"
KEYWORDS="*"

RDEPEND=">=media-libs/faad2-2.7-r3[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"

multilib_src_configure() {
	local emesonargs=(
		-Dgpl=enabled
	)

	gstreamer_multilib_src_configure
}
