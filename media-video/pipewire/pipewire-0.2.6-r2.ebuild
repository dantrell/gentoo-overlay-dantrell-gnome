# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit meson

DESCRIPTION="Multimedia processing graphs"
HOMEPAGE="https://pipewire.org/"
SRC_URI="https://github.com/PipeWire/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

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

	"${FILESDIR}"/${PN}-0.2.6-reuse-fd-in-pipewiresrc.patch
	"${FILESDIR}"/${PN}-0.2.6-fix-probing-without-starting.patch
	"${FILESDIR}"/${PN}-0.2.6-revert-combine-all-perms.patch
)

src_configure() {
	local emesonargs=(
		$(meson_use doc docs)
		-D man=true
		$(meson_feature gstreamer)
		$(meson_use systemd)
	)
	meson_src_configure
}

pkg_postinst() {
	elog "Package has optional sys-auth/rtkit RUNTIME support that may be"
	elog "disabled by setting DISABLE_RTKIT env var."
}
