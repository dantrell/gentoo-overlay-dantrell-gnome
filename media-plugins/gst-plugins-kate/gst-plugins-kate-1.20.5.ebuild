# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="Kate overlay codec suppport plugin for GStreamer"
KEYWORDS="*"

RDEPEND="
	>=media-libs/libkate-0.1.7[${MULTILIB_USEDEP}]
	>=media-libs/libtiger-0.3.2[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"