# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="DTLS encoder/decoder with SRTP support plugin for GStreamer"
KEYWORDS="*"

RDEPEND="
	>=dev-libs/openssl-1.0.1:0=[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
