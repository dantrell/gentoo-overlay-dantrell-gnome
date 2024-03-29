# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPTION="Ladspa elements for Gstreamer"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=media-libs/ladspa-sdk-1.13-r2[${MULTILIB_USEDEP}]
	media-libs/liblrdf[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
