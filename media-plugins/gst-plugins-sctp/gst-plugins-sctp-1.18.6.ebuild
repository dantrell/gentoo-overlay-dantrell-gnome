# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="SCTP plugins for GStreamer"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=media-libs/gst-plugins-base-${PV}:1.0[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
