# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic autotools multilib-minimal

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="https://www.cairographics.org/ https://gitlab.freedesktop.org/cairo/cairo"
SRC_URI="https://www.cairographics.org/releases/${P}.tar.xz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="*"

IUSE="X aqua debug gles2-only +glib opengl static-libs +svg utils valgrind"

# Test causes a circular depend on gtk+... since gtk+ needs cairo but test needs gtk+ so we need to block it
RESTRICT="test"

BDEPEND="
	virtual/pkgconfig
	>=sys-devel/libtool-2"
RDEPEND="
	>=dev-libs/lzo-2.06-r1[${MULTILIB_USEDEP}]
	>=media-libs/fontconfig-2.10.92[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.5.0.1:2[png,${MULTILIB_USEDEP}]
	>=media-libs/libpng-1.6.10:0=[${MULTILIB_USEDEP}]
	sys-libs/binutils-libs:0=[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}]
	>=x11-libs/pixman-0.32.4[${MULTILIB_USEDEP}]
	gles2-only? ( >=media-libs/mesa-9.1.6[gles2,${MULTILIB_USEDEP}] )
	glib? ( >=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}] )
	opengl? ( >=media-libs/mesa-9.1.6[egl(+),X(+),${MULTILIB_USEDEP}] )
	X? (
		>=x11-libs/libXrender-0.9.8[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2[${MULTILIB_USEDEP}]
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libxcb-1.9.1[${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )
"

REQUIRED_USE="
	gles2-only? ( !opengl )
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.12.18-disable-test-suite.patch
	"${FILESDIR}"/${PN}-respect-fontconfig.patch
	"${FILESDIR}"/${PN}-1.16.0-pdf-add-missing-flush.patch
	"${FILESDIR}"/${PN}-1.16.0-ft-Use-FT_Done_MM_Var-instead-of-free-when-available.patch
	"${FILESDIR}"/${PN}-1.16.0-strings.patch
)

src_prepare() {
	default

	if has_version ">=sys-libs/binutils-libs-2.34"; then
		eapply "${FILESDIR}"/${PN}-1.16.0-binutils-2.34.patch
	fi

	# tests and perf tools require X, bug #483574
	if ! use X; then
		sed -e '/^SUBDIRS/ s#boilerplate test perf# #' -i Makefile.am || die
	fi

	eautoreconf
}

multilib_src_configure() {
	local myopts

	[[ ${CHOST} == *-interix* ]] && append-flags -D_REENTRANT

	ECONF_SOURCE="${S}" \
	econf \
		$(use_with X x) \
		$(use_enable X tee) \
		$(use_enable X xlib) \
		$(use_enable X xlib-xrender) \
		$(use_enable X xcb) \
		$(use_enable X xcb-shm) \
		$(use_enable aqua quartz) \
		$(use_enable aqua quartz-image) \
		$(use_enable debug test-surfaces) \
		$(use_enable gles2-only glesv2) \
		$(use_enable glib gobject) \
		$(use_enable opengl gl) \
		$(use_enable static-libs static) \
		$(use_enable svg) \
		$(use_enable utils trace) \
		$(use_enable valgrind) \
		--enable-ft \
		--enable-interpreter \
		--enable-pdf \
		--enable-png \
		--enable-ps \
		--enable-script \
		--disable-drm \
		--disable-directfb \
		--disable-gallium \
		--disable-qt \
		--disable-vg \
		--disable-xlib-xcb \
		${myopts}
}

multilib_src_install_all() {
	find "${D}" -name '*.la' -delete || die
	einstalldocs
}
