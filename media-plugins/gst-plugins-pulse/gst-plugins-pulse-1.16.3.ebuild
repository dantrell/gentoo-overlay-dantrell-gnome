# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer

DESCRIPTION="PulseAudio sound server plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=media-libs/gst-plugins-base-${PV}:${SLOT}[${MULTILIB_USEDEP}]
	>=media-sound/pulseaudio-2.1-r1[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
