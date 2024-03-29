# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="Lv2 elements for Gstreamer"
KEYWORDS="*"

RDEPEND="
	>=media-libs/lv2-1.14.0-r1[${MULTILIB_USEDEP}]
	>=media-libs/lilv-0.24.2-r2[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
