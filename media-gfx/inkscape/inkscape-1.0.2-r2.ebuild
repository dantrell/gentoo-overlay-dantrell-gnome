# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
PYTHON_REQ_USE="xml(+)"

inherit cmake flag-o-matic xdg toolchain-funcs python-single-r1

DESCRIPTION="SVG based generic vector-drawing program"
HOMEPAGE="https://inkscape.org/ https://gitlab.com/inkscape/inkscape/"
SRC_URI="https://dev.gentoo.org/~zlogene/distfiles/${CATEGORY}/${PN}/${P}.tar.xz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="cdr dbus dia exif graphicsmagick imagemagick inkjar jemalloc jpeg lcms
openmp postscript spell static-libs svg2 visio wpg"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="test"

BDEPEND="
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"
COMMON_DEPEND="${PYTHON_DEPS}
	<app-text/poppler-22.0
	>=app-text/poppler-0.57.0:=[cairo]
	>=dev-cpp/cairomm-1.12:0
	>=dev-cpp/glibmm-2.54.1:2
	dev-cpp/gtkmm:3.0
	>=dev-cpp/pangomm-2.40:1.4
	>=dev-libs/boehm-gc-7.1:=
	dev-libs/boost:=
	dev-libs/double-conversion:=
	>=dev-libs/glib-2.41
	>=dev-libs/libsigc++-2.8:2
	>=dev-libs/libxml2-2.7.4
	>=dev-libs/libxslt-1.1.25
	dev-libs/gdl:3
	dev-libs/popt
	media-gfx/potrace
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libpng:0=
	net-libs/libsoup:2.4
	sci-libs/gsl:=
	x11-libs/libX11
	>=x11-libs/pango-1.37.2
	>=x11-libs/gtk+-3.22:3
	$(python_gen_cond_dep '
		dev-python/lxml[${PYTHON_USEDEP}]
		media-gfx/scour[${PYTHON_USEDEP}]
	')
	cdr? (
		app-text/libwpg:0.3
		dev-libs/librevenge
		media-libs/libcdr
	)
	dbus? ( dev-libs/dbus-glib )
	exif? ( media-libs/libexif )
	imagemagick? (
		!graphicsmagick? ( media-gfx/imagemagick:=[cxx] )
		graphicsmagick? ( media-gfx/graphicsmagick:=[cxx] )
	)
	jemalloc? ( dev-libs/jemalloc )
	jpeg? ( media-libs/libjpeg-turbo:0= )
	lcms? ( media-libs/lcms:2 )
	spell? (
		app-text/aspell
		app-text/gtkspell:3
	)
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
DEPEND="${COMMON_DEPEND}"

S="${WORKDIR}"/${P}_2021-01-15_e86c870879

PATCHES=(
	"${FILESDIR}"/${PN}-1.0.2-glib-2.67.3.patch
	# From Inkscape:
	# 	https://gitlab.com/inkscape/inkscape/commit/5724c21b9cb7b6176a7b36ca24068b148c817e82
	"${FILESDIR}"/${PN}-1.1-poppler-21.11.0.patch
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
	python-single-r1_pkg_setup
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
		-DENABLE_POPPLER=ON
		-DWITH_NLS=ON
		-DENABLE_POPPLER_CAIRO=ON
		-DWITH_PROFILING=OFF
		-DWITH_LIBCDR=$(usex cdr)
		-DWITH_DBUS=$(usex dbus)
		-DWITH_IMAGE_MAGICK=$(usex imagemagick $(usex !graphicsmagick)) # requires ImageMagick 6, only IM must be enabled
		-DWITH_GRAPHICS_MAGICK=$(usex graphicsmagick $(usex imagemagick)) # both must be enabled to use GraphicsMagick
		-DWITH_JEMALLOC=$(usex jemalloc)
		-DENABLE_LCMS=$(usex lcms)
		-DWITH_OPENMP=$(usex openmp)
		-DBUILD_SHARED_LIBS=$(usex !static-libs)
		-DWITH_SVG2=$(usex svg2)
		-DWITH_LIBVISIO=$(usex visio)
		-DWITH_LIBWPG=$(usex wpg)
	)

	cmake_src_configure
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
