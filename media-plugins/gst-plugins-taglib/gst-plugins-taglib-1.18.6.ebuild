# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer-meson

DESCRIPTION="ID3v2/APEv2 tagger plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-libs/taglib-1.9.1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
