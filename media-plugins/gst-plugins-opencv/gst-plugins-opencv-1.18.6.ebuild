# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE=gst-plugins-bad
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gstreamer-meson python-any-r1

DESCRIPTION="OpenCV elements for GStreamer"
KEYWORDS="*"

IUSE=""

# >=opencv-4.1.2-r3 to help testing removal of older being fine
RDEPEND="
	>=media-libs/opencv-4.1.2-r3:=[contrib,contribdnn,${MULTILIB_USEDEP}]
	<media-libs/opencv-4.6.0
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

PATCHES=(
	"${FILESDIR}"/gst-plugins-bad-1.18.4-use-system-libs-opencv.patch
)

src_prepare() {
	default
	gstreamer_system_package video_dep:gstreamer-video
}

multilib_src_install() {
	DESTDIR="${D}" eninja install
}
