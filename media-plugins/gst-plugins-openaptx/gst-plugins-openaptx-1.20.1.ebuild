# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="openaptx plugin for GStreamer"
KEYWORDS="*"

RDEPEND="
	|| (
		>=media-libs/libfreeaptx-0.1.1[${MULTILIB_USEDEP}]
		=media-libs/libopenaptx-0.2.0*[${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
