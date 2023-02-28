# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE="gst-plugins-ugly"
PYTHON_COMPAT=( python{3_9,3_10,3_11} )

inherit gstreamer-meson python-any-r1

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="https://gstreamer.freedesktop.org/"

LICENSE="LGPL-2+" # some split plugins are LGPL but combining with a GPL library
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=media-libs/gst-plugins-base-${PV}:${SLOT}[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

DOCS=( AUTHORS ChangeLog NEWS README.md RELEASE )

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}
