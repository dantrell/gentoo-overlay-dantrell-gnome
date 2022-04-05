# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-ugly

inherit gstreamer

DESCRIPTION="CD Audio Source (cdda) plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=dev-libs/libcdio-0.90-r1:=[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
