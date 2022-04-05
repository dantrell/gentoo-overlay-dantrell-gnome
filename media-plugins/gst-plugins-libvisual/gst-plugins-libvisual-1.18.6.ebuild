# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-base

inherit gstreamer-meson

DESCRIPTION="Visualization elements for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=media-libs/libvisual-0.4.0-r3[${MULTILIB_USEDEP}]
	>=media-plugins/libvisual-plugins-0.4.0-r3[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	gstreamer_system_package audio_dep:gstreamer-audio
	gstreamer_system_package pbutils_dep:gstreamer-pbutils
	gstreamer_system_package video_dep:gstreamer-video
}
