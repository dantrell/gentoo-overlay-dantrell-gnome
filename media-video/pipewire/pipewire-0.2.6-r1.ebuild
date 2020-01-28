# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit meson

MY_PV="${PV%_*}"
MY_P="${PN}-${MY_PV}"

S="${WORKDIR}/${MY_P}"

DESCRIPTION="Multimedia processing graphs"
HOMEPAGE="http://pipewire.org/"
SRC_URI="https://github.com/PipeWire/${PN}/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="doc gstreamer systemd"

RESTRICT="mirror"

RDEPEND="
	>=media-libs/alsa-lib-1.1.9
	media-libs/libv4l
	media-libs/sbc
	media-video/ffmpeg:=
	sys-apps/dbus
	virtual/libudev
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
	systemd? ( sys-apps/systemd )
"
DEPEND="
	${RDEPEND}
	app-doc/xmltoman
	doc? ( app-doc/doxygen )
"

PATCHES=(
	# From PipeWire:
	# 	https://github.com/PipeWire/pipewire/commit/37613b67ba52b5ad4e81d7ea38adc04027d9f9e5
	"${FILESDIR}"/${PN}-0.2.6-alsa-handle-alsa-lib-1-1-9.patch
)

src_configure() {
	local emesonargs=(
		$(meson_use doc docs)
		-D man=true
		$(meson_feature gstreamer gstreamer)
		$(meson_use systemd systemd)
	)
	meson_src_configure
}
