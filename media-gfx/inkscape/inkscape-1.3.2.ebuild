# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
PYTHON_REQ_USE="xml(+)"
MY_P="${P/_/}"

inherit cmake flag-o-matic xdg toolchain-funcs python-single-r1

DESCRIPTION="SVG based generic vector-drawing program"
HOMEPAGE="https://inkscape.org/ https://gitlab.com/inkscape/inkscape/"
SRC_URI="https://media.inkscape.org/dl/resources/file/${P}.tar.xz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~*"

IUSE="cdr dia exif graphicsmagick imagemagick inkjar jpeg openmp postscript readline sourceview spell svg2 test visio wpg X"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Lots of test failures which need investigating, bug #871621
RESTRICT="test"

BDEPEND="
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	test? ( virtual/imagemagick-tools )
"
COMMON_DEPEND="${PYTHON_DEPS}
	<app-text/poppler-23.0
	>=app-text/poppler-0.57.0:=[cairo]
	>=dev-cpp/cairomm-1.12:0
	>=dev-cpp/glibmm-2.54.1:2
	>=dev-cpp/gtkmm-3.24:3.0
	>=dev-cpp/pangomm-2.40:1.4
	>=dev-libs/boehm-gc-7.1:=
	dev-libs/boost:=[stacktrace(-)]
	dev-libs/double-conversion:=
	>=dev-libs/glib-2.41
	>=dev-libs/libsigc++-2.8:2
	>=dev-libs/libxml2-2.7.4
	>=dev-libs/libxslt-1.1.25
	dev-libs/popt
	media-gfx/potrace
	media-libs/libepoxy
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/lcms:2
	media-libs/libpng:0=
	net-libs/libsoup:2.4
	sci-libs/gsl:=
	>=x11-libs/pango-1.44
	>=x11-libs/gtk+-3.22:3[X?]
	X? ( x11-libs/libX11 )
	$(python_gen_cond_dep '
		dev-python/appdirs[${PYTHON_USEDEP}]
		dev-python/cachecontrol[${PYTHON_USEDEP}]
		dev-python/cssselect[${PYTHON_USEDEP}]
		dev-python/lockfile[${PYTHON_USEDEP}]
		dev-python/lxml[${PYTHON_USEDEP}]
		media-gfx/scour[${PYTHON_USEDEP}]
	')
	cdr? (
		app-text/libwpg:0.3
		dev-libs/librevenge
		media-libs/libcdr
	)
	exif? ( media-libs/libexif )
	imagemagick? (
		!graphicsmagick? ( media-gfx/imagemagick:=[cxx] )
		graphicsmagick? ( media-gfx/graphicsmagick:=[cxx] )
	)
	jpeg? ( media-libs/libjpeg-turbo:0= )
	readline? ( sys-libs/readline:0= )
	sourceview? ( x11-libs/gtksourceview:4 )
	spell? ( app-text/gspell )
	visio? (
		app-text/libwpg:0.3
		dev-libs/librevenge
		media-libs/libvisio
	)
	wpg? (
		app-text/libwpg:0.3
		dev-libs/librevenge
	)
"
# These only use executables provided by these packages
# See share/extensions for more details. inkscape can tell you to
# install these so we could of course just not depend on those and rely
# on that.
RDEPEND="${COMMON_DEPEND}
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
	dia? ( app-office/dia )
	postscript? ( app-text/ghostscript-gpl )
"
DEPEND="${COMMON_DEPEND}
	test? ( dev-cpp/gtest )
"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	# From Inkscape:
	# 	https://gitlab.com/inkscape/inkscape/commit/694d8ae43d06efff21adebf377ce614d660b24cd
	"${FILESDIR}"/${PN}-1.3.2-libxml2-2.12.patch
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
	python-single-r1_pkg_setup
}

src_unpack() {
	default
	[[ -d "${S}" ]] || mv -v "${WORKDIR}/${P}_202"?-??-* "${S}" || die
}

src_prepare() {
	cmake_src_prepare
	sed -i "/install.*COPYING/d" CMakeScripts/ConfigCPack.cmake || die
}

src_configure() {
	# aliasing unsafe wrt #310393
	append-flags -fno-strict-aliasing

	local mycmakeargs=(
		# -DWITH_LPETOOL   # Compile with LPE Tool and experimental LPEs enabled
		-DWITH_NLS=ON
		-DENABLE_POPPLER=ON
		-DENABLE_POPPLER_CAIRO=ON
		-DWITH_PROFILING=OFF
		-DWITH_INTERNAL_CAIRO=OFF
		-DWITH_INTERNAL_2GEOM=ON
		-DBUILD_TESTING=$(usex test)
		-DWITH_LIBCDR=$(usex cdr)
		-DWITH_IMAGE_MAGICK=$(usex imagemagick $(usex !graphicsmagick)) # requires ImageMagick 6, only IM must be enabled
		-DWITH_GRAPHICS_MAGICK=$(usex graphicsmagick $(usex imagemagick)) # both must be enabled to use GraphicsMagick
		-DWITH_GNU_READLINE=$(usex readline)
		-DWITH_GSPELL=$(usex spell)
		-DWITH_JEMALLOC=OFF
		-DENABLE_LCMS=ON
		-DWITH_OPENMP=$(usex openmp)
		-DBUILD_SHARED_LIBS=ON
		-DWITH_GSOURCEVIEW=$(usex sourceview)
		-DWITH_SVG2=$(usex svg2)
		-DWITH_LIBVISIO=$(usex visio)
		-DWITH_LIBWPG=$(usex wpg)
		-DWITH_X11=$(usex X)
	)

	cmake_src_configure
}

src_test() {
	CMAKE_SKIP_TESTS=(
		# render_text*: needs patched Cairo / maybe upstream changes
		# not yet in a release.
		# test_lpe/test_lpe64: precision differences b/c of new GCC?
		# cli_export-png-color-mode-gray-8_png_check_output: ditto?
		render_test-use
		render_test-glyph-y-pos
		render_text-glyphs-combining
		render_text-glyphs-vertical
		render_test-rtl-vertical
		test_lpe
		test_lpe64
		cli_export-png-color-mode-gray-8_png_check_output
	)

	# bug #871621
	cmake_src_compile tests
	cmake_src_test -j1
}

src_install() {
	cmake_src_install

	find "${ED}" -type f -name "*.la" -delete || die

	find "${ED}"/usr/share/man -type f -maxdepth 3 -name '*.bz2' -exec bzip2 -d {} \; || die

	find "${ED}"/usr/share/man -type f -maxdepth 3 -name '*.gz' -exec gzip -d {} \; || die

	local extdir="${ED}"/usr/share/${PN}/extensions

	if [[ -e "${extdir}" ]] && [[ -n $(find "${extdir}" -mindepth 1) ]]; then
		python_optimize "${ED}"/usr/share/${PN}/extensions
	fi

	# Empty directory causes sandbox issues, see bug #761915
	rm -r "${ED}/usr/share/inkscape/fonts" || die "Failed to remove fonts directory."
}
