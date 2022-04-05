# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="DVD playback support plugin for GStreamer"
KEYWORDS="*"

RDEPEND="
	>=media-libs/libdvdnav-4.2.0-r1:=[${MULTILIB_USEDEP}]
	>=media-libs/libdvdread-4.2.0-r1:=[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"

multilib_src_configure() {
	local emesonargs=(
		-Dgpl=enabled
	)

	gstreamer_multilib_src_configure
}
