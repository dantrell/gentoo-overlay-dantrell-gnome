# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer

DESCRIPTION="MusicIP audio fingerprinting plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-libs/libofa-0.9.3-r1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
