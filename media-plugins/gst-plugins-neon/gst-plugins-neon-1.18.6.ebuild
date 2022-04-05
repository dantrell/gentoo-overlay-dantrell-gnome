# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="HTTP client source plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=net-libs/neon-0.30.0[${MULTILIB_USEDEP}]
	<=net-libs/neon-0.31.99[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
