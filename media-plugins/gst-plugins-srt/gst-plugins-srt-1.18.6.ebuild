# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="Secure reliable transport (SRT) transfer plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND="
	net-libs/srt:=[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
