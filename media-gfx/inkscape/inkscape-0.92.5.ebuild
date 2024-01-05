# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_10,3_11,3_12} )
PYTHON_REQ_USE="xml(+)"

inherit autotools flag-o-matic gnome2-utils xdg toolchain-funcs python-single-r1

MY_P="${P/_/}"

DESCRIPTION="SVG based generic vector-drawing program"
HOMEPAGE="https://inkscape.org/ https://gitlab.com/inkscape/inkscape/"
SRC_URI="https://inkscape.global.ssl.fastly.net/media/resources/file/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~*"

IUSE="cdr dbus deprecated dia exif gnome graphicsmagick imagemagick inkjar jpeg latex lcms
nls openmp postscript  spell static-libs uniconvertor visio wpg"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="test"

BDEPEND="
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"
COMMON_DEPEND="${PYTHON_DEPS}
	<app-text/poppler-22.0
	>=app-text/poppler-0.26.0:=[cairo]
	>=dev-cpp/cairomm-1.9.8
	>=dev-cpp/glibmm-2.28
	>=dev-cpp/gtkmm-2.18.0:2.4
	>=dev-libs/boehm-gc-7.1:=
	dev-libs/boost:=
	>=dev-libs/glib-2.28
	>=dev-libs/libsigc++-2.0.12
	>=dev-libs/libxml2-2.6.20
	>=dev-libs/libxslt-1.0.15
	dev-libs/popt
	media-gfx/potrace
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libpng:0=
	sci-libs/gsl:=
	x11-libs/libX11
	>=x11-libs/pango-1.24
	>=x11-libs/gtk+-2.10.7:2
	cdr? (
		app-text/libwpg:0.3
		dev-libs/librevenge
		media-libs/libcdr
	)
	dbus? ( dev-libs/dbus-glib )
	!deprecated? ( >=dev-cpp/glibmm-2.48 )
	exif? ( media-libs/libexif )
	gnome? ( >=gnome-base/gnome-vfs-2.0 )
	imagemagick? (
		!graphicsmagick? ( media-gfx/imagemagick:=[cxx] )
		graphicsmagick? ( media-gfx/graphicsmagick:=[cxx] )
	)
	jpeg? ( media-libs/libjpeg-turbo:0= )
	lcms? ( media-libs/lcms:2 )
	spell? (
		app-text/aspell
		app-text/gtkspell:2
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
	uniconvertor? ( media-gfx/uniconvertor )
	dia? ( app-office/dia )
	latex? (
		media-gfx/pstoedit[plotutils]
		app-text/dvipsk
		app-text/texlive-core
	)
	postscript? ( app-text/ghostscript-gpl )
"
DEPEND="${COMMON_DEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-0.92.1-automagic.patch
	"${FILESDIR}"/${PN}-0.91_pre3-cppflags.patch
	"${FILESDIR}"/${PN}-0.92.1-desktop.patch
	"${FILESDIR}"/${PN}-0.91_pre3-exif.patch
	"${FILESDIR}"/${PN}-0.91_pre3-sk-man.patch
	"${FILESDIR}"/${PN}-0.92.5-epython.patch
	# From Inkscape:
	# 	https://gitlab.com/inkscape/inkscape/commit/5724c21b9cb7b6176a7b36ca24068b148c817e82
	"${FILESDIR}"/${PN}-1.1-poppler-21.11.0.patch
)

S="${WORKDIR}/${MY_P}"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
	python-single-r1_pkg_setup
}

src_prepare() {
	default

	if has_version '>=dev-libs/glib-2.61.0'; then
		# From Inkscape:
		# 	https://gitlab.com/inkscape/inkscape/commit/9248a27415b51ae5674dd79d1738cf8f0549806f
		# 	https://gitlab.com/inkscape/inkscape/commit/c719ad24d6a57681566e7751d74829bff19c025f
		eapply "${FILESDIR}"/${PN}-0.92.4-move-from-deprecated-gtimeval.patch
	fi

	# From Inkscape:
	# 	https://gitlab.com/inkscape/inkscape/commit/287c3a7e92e205b721844fd871a3f5605d3709cd
	eapply -R "${FILESDIR}"/${PN}-0.92.5-hide-spellcheck-if-aspell-missing.patch

	# From Inkscape:
	# 	https://gitlab.com/inkscape/inkscape/commit/e4480c55484d8510e607c9b5c9f364fd750e636c
	eapply -R "${FILESDIR}"/${PN}-0.92.5-backport-from-master-remove-confusing-and-broken-save-as-png-option.patch

	# From Inkscape:
	# 	https://gitlab.com/inkscape/inkscape/commit/3570358cd11431ba88682b407dec9b6f42575956
	eapply "${FILESDIR}"/${PN}-0.92.5-update-bundled-documentation.patch

	sed -i "s#@EPYTHON@#${EPYTHON}#" \
		src/extension/implementation/script.cpp || die

	eautoreconf

	# bug 421111
	python_fix_shebang share/extensions
}

src_configure() {
	local myconf=()

	# aliasing unsafe wrt #310393
	append-flags -fno-strict-aliasing

	if use deprecated; then
		# disabling strict build required due to glibmm / glib2 deprecation misconfiguration
		# https://trac.macports.org/ticket/52248
		myconf+=(
			--disable-strict-build
		)
	else
		# Code is not C++17 ready (GCC 11 default)
		append-cxxflags -std=c++14
	fi

	local myeconfargs=(
		$(use_enable static-libs static)
		$(use_enable nls)
		$(use_enable openmp)
		$(use_enable exif)
		$(use_enable jpeg)
		$(use_enable lcms)
		--enable-poppler-cairo
		$(use_enable wpg)
		$(use_enable visio)
		$(use_enable cdr)
		$(use_enable dbus dbusapi)
		$(use_enable imagemagick magick)
		$(use_with gnome gnome-vfs)
		$(use_with inkjar)
		$(use_with spell gtkspell)
		$(use_with spell aspell)
		"${myconf[@]}"
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	emake -C src helper/sp-marshal.h #686304
	emake AR="$(tc-getAR)"
}

src_install() {
	default

	find "${ED}" -type f -name "*.la" -delete || die

	python_optimize "${ED}"/usr/share/${PN}/extensions
}
