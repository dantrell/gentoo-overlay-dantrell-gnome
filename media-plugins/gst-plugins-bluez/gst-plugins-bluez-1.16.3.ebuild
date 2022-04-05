# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer

DESCRIPTION="AVDTP source/sink and A2DP sink plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=net-wireless/bluez-5[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	dev-util/gdbus-codegen
"
