# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-ugly

inherit gstreamer

DESCRIPTION="DVD read plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-libs/libdvdread-4.2.0-r1:=[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
