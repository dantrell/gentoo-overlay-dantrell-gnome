# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE="gst-plugins-ugly"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gstreamer-meson python-any-r1

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="https://gstreamer.freedesktop.org/"

LICENSE="LGPL-2+" # some split plugins are LGPL but combining with a GPL library
KEYWORDS="*"

IUSE="+orc"

RDEPEND="
	>=media-libs/gst-plugins-base-${PV}:${SLOT}[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	>=dev-build/gtk-doc-am-1.12
"

DOCS="AUTHORS ChangeLog NEWS README RELEASE"

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}
