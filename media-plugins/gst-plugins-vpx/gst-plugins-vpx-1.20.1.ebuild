# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer-meson

DESCRIPTION="VP8/VP9 video encoder/decoder plugin for GStreamer"
KEYWORDS="*"

RDEPEND=">=media-libs/libvpx-1.7.0:=[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
