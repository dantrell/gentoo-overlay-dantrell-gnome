# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer

DESCRIPTION="Beats-per-minute detection and pitch controlling plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-libs/libsoundtouch-1.7.1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
