# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer

DESCRIPTION="Calculate Chromaprint fingerprint from audio files for GStreamer"
KEYWORDS="*"

RDEPEND="media-libs/chromaprint[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
