# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer-meson

DESCRIPTION="Video overlay plugin based on cairo for GStreamer"
KEYWORDS="*"

RDEPEND=">=x11-libs/cairo-1.10[glib,${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
