# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer

DESCRIPTION="Speex encoder/decoder plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-libs/speex-1.2_rc1-r1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
