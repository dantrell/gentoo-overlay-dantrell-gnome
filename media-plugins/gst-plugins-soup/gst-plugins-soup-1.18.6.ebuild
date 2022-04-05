# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer-meson

DESCRIPTION="HTTP client source/sink plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=net-libs/libsoup-2.48:2.4[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
