# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE="gst-plugins-bad"

inherit gstreamer

DESCRIPTION="H.265 encoder plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND="
	media-libs/x265:=[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
