# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit meson

DESCRIPTION="Multimedia processing graphs"
HOMEPAGE="https://pipewire.org/"
SRC_URI="https://github.com/PipeWire/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0/0.3"
KEYWORDS="*"

IUSE="alsa bluetooth doc examples ffmpeg gstreamer jack pulseaudio sdl systemd test vaapi vulkan X"

RESTRICT="!test? ( test )"

BDEPEND="
	app-doc/xmltoman
	doc? (
		app-doc/doxygen
		media-gfx/graphviz
	)
"
DEPEND="
	alsa? ( media-libs/alsa-lib )
	sys-apps/dbus
	virtual/libudev
	bluetooth? ( media-libs/sbc )
	ffmpeg? ( media-video/ffmpeg:= )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
	jack? ( media-sound/jack2 )
	pulseaudio? ( media-sound/pulseaudio )
	sdl? ( media-libs/libsdl2 )
	systemd? ( sys-apps/systemd )
	vaapi? ( x11-libs/libva )
	vulkan? ( media-libs/vulkan-loader )
	X? ( x11-libs/libX11 )
"
RDEPEND="${DEPEND}"

src_prepare() {
	spa_use() {
		if ! use ${1}; then
			sed -e "/.*dependency.*'${2-$1}'/s/'${2-$1}'/'${2-$1}-disabled-by-USE-no-${1}'/" \
				-i spa/meson.build || die
		fi
	}

	default
	spa_use bluetooth sbc
	spa_use ffmpeg libavcodec
	spa_use ffmpeg libavformat
	spa_use ffmpeg libavfilter
	spa_use vaapi libva
	spa_use sdl sdl2
	spa_use X x11
}

src_configure() {
	local emesonargs=(
		$(meson_use doc docs)
		$(meson_use examples)
		-Dman=true
		$(meson_use test tests)
		$(meson_use gstreamer)
		$(meson_use systemd)
		$(meson_use alsa pipewire-alsa)
		$(meson_use jack pipewire-jack)
		$(meson_use pulseaudio pipewire-pulseaudio)
		$(meson_use alsa)
		$(meson_use bluetooth bluez5)
		$(meson_use ffmpeg)
		$(meson_use jack)
		$(meson_use vulkan)
	)
	meson_src_configure
}

pkg_postinst() {
	elog "Package has optional sys-auth/rtkit RUNTIME support that may be"
	elog "disabled by setting DISABLE_RTKIT env var."
}
