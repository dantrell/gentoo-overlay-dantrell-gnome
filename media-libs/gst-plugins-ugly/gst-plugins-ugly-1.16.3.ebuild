# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GST_ORG_MODULE="gst-plugins-ugly"

inherit gstreamer

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="https://gstreamer.freedesktop.org/"

LICENSE="LGPL-2+" # some split plugins are LGPL but combining with a GPL library
KEYWORDS="*"

RDEPEND="
	>=dev-libs/glib-2.40.0:2[${MULTILIB_USEDEP}]
	>=media-libs/gstreamer-${PV}:${SLOT}[${MULTILIB_USEDEP}]
	>=media-libs/gst-plugins-base-${PV}:${SLOT}[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.12
"

multilib_src_configure() {
	gstreamer_multilib_src_configure

	if multilib_is_native_abi; then
		ln -s "${S}"/docs/plugins/html docs/plugins/html || die
	fi
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}
