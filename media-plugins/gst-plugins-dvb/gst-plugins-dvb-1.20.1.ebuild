# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer-meson

DESCRIPION="DVB device capture plugin for GStreamer"
KEYWORDS="*"

RDEPEND=""
DEPEND="virtual/os-headers"

src_prepare() {
	default
	gstreamer_system_package gstmpegts_dep:gstreamer-mpegts
}
