# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="AAC audio encoder plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-libs/faac-1.28-r3[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
