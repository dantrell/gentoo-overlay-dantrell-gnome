# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="H.264 encoder/decoder plugin for GStreamer"
KEYWORDS="*"

RDEPEND="
	>=media-libs/openh264-1.3:=[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
