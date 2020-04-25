# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_EAUTORECONF="yes"

inherit gnome2 multilib

DESCRIPTION="A library for using 3D graphics hardware to draw pretty pictures"
HOMEPAGE="https://www.cogl3d.org/"

LICENSE="MIT BSD"
SLOT="1.0/20" # subslot = .so version
KEYWORDS="*"

IUSE="doc debug examples gles2 gstreamer +introspection +pango wayland"

# Need classic mesa swrast for tests, llvmpipe causes a test failure
# For some reason GL3 conformance test all fails again...
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.32:2
	x11-libs/cairo:=
	>=x11-libs/gdk-pixbuf-2:2
	x11-libs/libX11
	>=x11-libs/libXcomposite-0.4
	x11-libs/libXdamage
	x11-libs/libXext
	>=x11-libs/libXfixes-3
	>=x11-libs/libXrandr-1.2
	media-libs/mesa[egl]
	gles2? ( media-libs/mesa[gles2] )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0 )
	introspection? ( >=dev-libs/gobject-introspection-1.34.2:= )
	pango? ( >=x11-libs/pango-1.20.0[introspection?] )
	wayland? (
		>=dev-libs/wayland-1.1.90
		media-libs/mesa[egl,gbm,wayland]
		x11-libs/libdrm:=
	)
"
# before clutter-1.7, cogl was part of clutter
RDEPEND="${COMMON_DEPEND}
	!<media-libs/clutter-1.7
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/gtk-doc-am-1.13
	>=sys-devel/gettext-0.19
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.22.2-eglmesaext-include.patch
)

src_prepare() {
	# Do not build examples
	sed -e "s/^\(SUBDIRS +=.*\)examples\(.*\)$/\1\2/" \
		-i Makefile.am Makefile.in || die

	#if ! use test ; then
	# For some reason the configure switch will not completely disable
	# tests being built
	sed -e "s/^\(SUBDIRS =.*\)test-fixtures\(.*\)$/\1\2/" \
		-e "s/^\(SUBDIRS +=.*\)tests\(.*\)$/\1\2/" \
		-e "s/^\(.*am__append.* \)tests\(.*\)$/\1\2/" \
		-i Makefile.am Makefile.in || die
	#fi

	gnome2_src_prepare
}

src_configure() {
	# Prefer gl driver by default
	# Profiling needs uprof, which is not available in portage yet, bug #484750
	# native backend without wayland is useless
	gnome2_src_configure \
		--disable-examples-install \
		--disable-maintainer-flags \
		--enable-cairo \
		--enable-deprecated \
		--enable-gdk-pixbuf \
		--enable-gl \
		--enable-glib \
		--enable-glx \
		--disable-profile \
		--with-default-driver=gl \
		$(use_enable debug) \
		$(use_enable doc gtk-doc) \
		$(use_enable gles2) \
		$(use_enable gles2 cogl-gles2) \
		$(use_enable gles2 xlib-egl-platform) \
		$(use_enable gstreamer cogl-gst) \
		$(use_enable introspection) \
		$(use_enable pango cogl-pango) \
		--disable-unit-tests \
		$(use_enable wayland kms-egl-platform) \
		$(use_enable wayland wayland-egl-platform) \
		$(use_enable wayland wayland-egl-server)
}

src_install() {
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/{*.c,*.jpg}
	fi

	gnome2_src_install

	# Remove silly examples-data directory
	rm -rvf "${ED}/usr/share/cogl/examples-data/" || die
}
