# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer

DESCRIPTION="MPEG/DVD/SVCD/VCD video/audio multiplexing plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-video/mjpegtools-2.1.0-r1:=[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
