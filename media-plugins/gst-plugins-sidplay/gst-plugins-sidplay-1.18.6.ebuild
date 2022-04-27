# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-ugly

inherit gstreamer-meson

DESCRIPTION="Sid decoder plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-libs/libsidplay-1.36.59-r1:1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"