# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-base

inherit gstreamer-meson

DESCRIPTION="CD Audio Source (cdda) plugin for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=media-sound/cdparanoia-3.10.2-r6[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	gstreamer_system_package audio_dep:gstreamer-audio
}
