# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer

DESCRIPTION="SRTP encoder/decoder plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=net-libs/libsrtp-2.1.0:2=[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
