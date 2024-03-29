# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-good

inherit gstreamer

DESCRIPTION="Video overlay plugin based on cairo for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND=">=x11-libs/cairo-1.10[glib,${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
