# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer-meson

DESCRIPTION="MP3 encoder plugin for GStreamer"
KEYWORDS="*"

RDEPEND=">=media-sound/lame-3.99.5-r1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
