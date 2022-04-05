# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer

DESCRIPTION="MPEG2 encoder plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-sound/twolame-0.3.13-r1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
