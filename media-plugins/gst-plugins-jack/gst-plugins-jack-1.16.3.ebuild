# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer

DESCRIPION="JACK audio server source/sink plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND="virtual/jack[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
