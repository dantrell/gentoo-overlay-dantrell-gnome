# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-ugly

inherit gstreamer

DESCRIPTION="MPEG2 decoder plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-libs/libmpeg2-0.5.1-r2[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
