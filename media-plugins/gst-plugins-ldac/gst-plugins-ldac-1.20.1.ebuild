# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="LDAC plugin for GStreamer"
KEYWORDS="*"

RDEPEND="media-libs/libldac[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
