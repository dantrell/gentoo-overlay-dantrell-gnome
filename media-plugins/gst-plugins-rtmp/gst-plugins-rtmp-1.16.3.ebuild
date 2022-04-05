# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer

DESCRIPTION="RTMP source/sink plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-video/rtmpdump-2.4_p20131018[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
