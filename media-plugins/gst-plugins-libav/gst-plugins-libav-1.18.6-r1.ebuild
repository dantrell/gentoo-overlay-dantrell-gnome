# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gstreamer-meson

MY_PN="gst-libav"
MY_PV="$(ver_cut 1-3)"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="FFmpeg based gstreamer plugin"
HOMEPAGE="https://gstreamer.freedesktop.org/modules/gst-libav.html"
SRC_URI="https://gstreamer.freedesktop.org/src/${MY_PN}/${MY_P}.tar.xz"

SRC_URI+=" https://cmpct.info/~sam/gentoo/distfiles/${CATEGORY}/${PN}/${PN}-1.18.4_ffmpeg-5.patch.bz2"
S="${WORKDIR}/${MY_P}"

LICENSE="LGPL-2+"
SLOT="1.0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.40.0:2[${MULTILIB_USEDEP}]
	>=media-libs/gstreamer-${MY_PV}:1.0[${MULTILIB_USEDEP}]
	>=media-libs/gst-plugins-base-${MY_PV}:1.0[${MULTILIB_USEDEP}]
	>=media-video/ffmpeg-4:0=[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${WORKDIR}/${PN}-1.18.4_ffmpeg-5.patch"
)
