# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome.org gnome2-utils meson python-any-r1 xdg

DESCRIPTION="Simple sound recorder"
HOMEPAGE="https://wiki.gnome.org/Design/Apps/SoundRecorder"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

DEPEND="
	>=dev-libs/gjs-1.54.0
	>=dev-libs/glib-2.46:2
	>=x11-libs/gtk+-3.12:3[introspection]
	media-libs/gst-plugins-bad:1.0
	>=gui-libs/libhandy-1.1.90:1=
	>=dev-libs/gobject-introspection-1.31.6:=
	x11-libs/gdk-pixbuf:2[introspection]
"
RDEPEND="${DEPEND}
	media-libs/gstreamer:1.0[introspection]
	media-libs/gst-plugins-base:1.0[introspection,ogg]
	media-libs/gst-plugins-good:1.0
	media-plugins/gst-plugins-flac:1.0
	media-plugins/gst-plugins-pulse:1.0
"
BDEPEND="
	${PYTHON_DEPS}
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	# From Gentoo:
	# 	https://bugs.gentoo.org/831924
	"${FILESDIR}"/${PN}-40.0-fix-build-with-meson-0.61.1.patch
)

pkg_setup() {
	python-any-r1_pkg_setup
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
