# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer

DESCRIPTION="Color management correction GStreamer plugins"
KEYWORDS="*"

RDEPEND=">=media-libs/lcms-2.7:2[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"

GST_PLUGINS_BUILD="lcms2"
