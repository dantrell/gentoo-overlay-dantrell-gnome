# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="Color management correction GStreamer plugins"
KEYWORDS="*"

RDEPEND=">=media-libs/lcms-2.7:2[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
