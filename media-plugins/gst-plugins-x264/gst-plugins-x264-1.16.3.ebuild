# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-ugly

inherit gstreamer

DESCRIPTION="H.264 encoder plugin for GStreamer"
KEYWORDS="*"

IUSE=""

# 20111220 ensures us X264_BUILD >= 120
RDEPEND=">=media-libs/x264-0.0.20130506:=[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
