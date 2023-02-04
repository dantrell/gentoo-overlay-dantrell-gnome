# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="MOD audio decoder plugin for GStreamer"
KEYWORDS="*"

RDEPEND=">=media-libs/libmodplug-0.8.8.4-r1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
