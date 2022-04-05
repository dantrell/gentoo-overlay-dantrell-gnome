# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer-meson

DESCRIPION="JACK audio server source/sink plugin for GStreamer"
KEYWORDS="*"

IUSE=""

# >=jack-1.9.7 is provided by pipewire[jack-sdk] as well
RDEPEND="|| (
	media-sound/jack2[${MULTILIB_USEDEP}]
	media-video/pipewire[jack-sdk(-),${MULTILIB_USEDEP}]
)"
DEPEND="${RDEPEND}"
