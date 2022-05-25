# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer-meson

DESCRIPTION="JPEG image encoder/decoder plugin for GStreamer"
KEYWORDS="*"

RDEPEND="media-libs/libjpeg-turbo:0=[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
