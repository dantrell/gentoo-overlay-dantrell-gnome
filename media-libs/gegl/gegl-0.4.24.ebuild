# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
# vala and introspection support is broken, bug #468208
VALA_USE_DEPEND=vapigen

inherit meson gnome2-utils python-any-r1 vala

DESCRIPTION="A graph based image processing framework"
HOMEPAGE="https://gegl.org/"
SRC_URI="https://download.gimp.org/pub/${PN}/${PV:0:3}/${P}.tar.xz"

LICENSE="|| ( GPL-3+ LGPL-3 )"
SLOT="0.4"
KEYWORDS="*"

IUSE="cairo debug ffmpeg introspection lcms lensfun openexr pdf raw sdl svg test tiff umfpack vala v4l webp"
REQUIRED_USE="
	svg? ( cairo )
	test? ( introspection )
	vala? ( introspection )
"

RESTRICT="!test? ( test )"

# NOTE: Even current libav 11.4 does not have AV_CODEC_CAP_VARIABLE_FRAME_SIZE
#       so there is no chance to support libav right now (Gentoo bug #567638)
#       If it returns, please check prior GEGL ebuilds for how libav was integrated.  Thanks!
RDEPEND="
	>=dev-libs/glib-2.44:2
	>=dev-libs/json-glib-1.2.6
	>=media-libs/babl-0.1.78[introspection?,lcms?,vala?]
	media-libs/libnsgif
	>=media-libs/libpng-1.6.0:0=
	>=sys-libs/zlib-1.2.0
	media-libs/libjpeg-turbo:0=
	>=x11-libs/gdk-pixbuf-2.32:2
	>=x11-libs/pango-1.38.0
	cairo? ( >=x11-libs/cairo-1.12.2 )
	ffmpeg? ( media-video/ffmpeg:0= )
	introspection? ( >=dev-libs/gobject-introspection-1.32:= )
	lcms? ( >=media-libs/lcms-2.8:2 )
	lensfun? ( >=media-libs/lensfun-0.2.5 )
	openexr? ( >=media-libs/openexr-1.6.1:= )
	pdf? ( >=app-text/poppler-0.71.0[cairo] )
	raw? ( >=media-libs/libraw-0.15.4:0= )
	sdl? ( >=media-libs/libsdl-1.2.0 )
	svg? ( >=gnome-base/librsvg-2.40.6:2 )
	tiff? ( >=media-libs/tiff-4:= )
	umfpack? ( sci-libs/umfpack )
	v4l? ( >=media-libs/libv4l-1.0.1 )
	webp? ( >=media-libs/libwebp-0.5.0:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-lang/perl
	>=dev-build/gtk-doc-am-1
	>=sys-devel/gettext-0.19.8
	>=dev-build/libtool-2.2
	virtual/pkgconfig
	test? ( $(python_gen_any_dep '>=dev-python/pygobject-3.2:3[${PYTHON_USEDEP}]') )
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.4.18-drop-failing-tests.patch
	"${FILESDIR}"/${PN}-0.4.18-program-suffix.patch
)

python_check_deps() {
	use test || return 0
	python_has_version ">=dev-python/pygobject-3.2:3[${PYTHON_USEDEP}]"
}

src_prepare() {
	default

	# don't require Apple's OpenCL on versions of OSX that don't have it
	if [[ ${CHOST} == *-darwin* && ${CHOST#*-darwin} -le 9 ]] ; then
		sed -i -e 's/#ifdef __APPLE__/#if 0/' gegl/opencl/* || die
	fi

	# commit 7c78497b : tests that use gegl.png are broken on non-amd64
	sed -e '/clones.xml/d' \
		-e '/composite-transform.xml/d' \
		-i tests/compositions/meson.build || die

	# fix skipping mipmap tests due to executable not found
	for item in "invert-crop.sh" "invert.sh" "rotate-crop.sh" "rotate.sh" "unsharp-crop.sh" "unsharp.sh"; do
		sed -i "s:/bin/gegl:/bin/gegl-0.4:g" "${S}/tests/mipmap/${item}" || die
		sed -i "s:/tools/gegl-imgcmp:/tools/gegl-imgcmp-0.4:g" "${S}/tests/mipmap/${item}" || die
	done

	if use openexr && has_version '>=dev-libs/glib-2.67.3'; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/glib/-/issues/2331
		# 	https://bugs.gentoo.org/793998
		eapply "${FILESDIR}"/${PN}-0.4.26-fix-build-glib-2.67.3.patch
	fi

	gnome2_environment_reset

	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		#  - Disable documentation as the generating is bit automagic
		#    if anyone wants to work on it just create bug with patch
		-Ddocs=false
		-Dexiv2=disabled
		-Dgdk-pixbuf=enabled
		-Dgexiv2=disabled
		#  - There are two checks for dot, one controllable by --with(out)-graphviz
		#    which toggles HAVE_GRAPHVIZ that is not used anywhere.  Yes.
		-Dgraphviz=disabled
		-Djasper=disabled
		-Dlibjpeg=enabled
		-Dlibpng=enabled
		#  - libspiro: not in portage main tree
		-Dlibspiro=disabled
		-Dlua=disabled
		-Dmrg=disabled
		-Dpango=enabled
		-Dsdl2=disabled
		#  - Parameter -Dworkshop=false disables any use of Lua, effectivly
		-Dworkshop=false
		$(meson_feature cairo)
		$(meson_feature cairo pangocairo)
		$(meson_feature ffmpeg libav)
		$(meson_feature lcms)
		$(meson_feature lensfun)
		$(meson_feature openexr)
		$(meson_feature pdf poppler)
		$(meson_feature raw libraw)
		$(meson_feature sdl sdl1)
		$(meson_feature svg librsvg)
		$(meson_feature test pygobject)
		$(meson_feature tiff libtiff)
		$(meson_feature umfpack)
		#  - v4l support does not work with our media-libs/libv4l-0.8.9,
		#    upstream bug at https://bugzilla.gnome.org/show_bug.cgi?id=654675
		$(meson_feature v4l libv4l)
		$(meson_feature v4l libv4l2)
		$(meson_feature vala vapigen)
		$(meson_feature webp)
		$(meson_use introspection)
	)
	meson_src_configure
}
