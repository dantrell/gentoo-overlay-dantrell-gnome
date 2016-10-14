# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="xml"

inherit autotools eutils flag-o-matic gnome2-utils fdo-mime toolchain-funcs python-single-r1

MY_P=${P/_/}

DESCRIPTION="A SVG based generic vector-drawing program"
HOMEPAGE="http://www.inkscape.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="dia gnome postscript inkjar lcms nls spell wmf"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="test"

COMMON_DEPEND="
	${PYTHON_DEPS}
	app-text/libwpd:0.9
	app-text/libwpg:0.2
	>=app-text/poppler-0.12.3-r3:=[cairo,xpdf-headers(+)]
	dev-cpp/glibmm
	>=dev-cpp/gtkmm-2.18.0:2.4
	>=dev-libs/boehm-gc-6.4
	>=dev-libs/glib-2.6.5
	>=dev-libs/libsigc++-2.0.12
	>=dev-libs/libxml2-2.6.20
	>=dev-libs/libxslt-1.0.15
	dev-libs/popt
	dev-python/lxml[${PYTHON_USEDEP}]
	media-gfx/imagemagick[cxx]
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libpng:0
	sci-libs/gsl:=
	x11-libs/libX11
	>=x11-libs/gtk+-2.10.7:2
	>=x11-libs/pango-1.4.0
	gnome? ( >=gnome-base/gnome-vfs-2.0 )
	lcms? ( media-libs/lcms:2 )
	spell? (
		app-text/aspell
		app-text/gtkspell:2
	)
"

# These only use executables provided by these packages
# See share/extensions for more details. inkscape can tell you to
# install these so we could of course just not depend on those and rely
# on that.
RDEPEND="${COMMON_DEPEND}
	dev-python/numpy[${PYTHON_USEDEP}]
	media-gfx/uniconvertor
	dia? ( app-office/dia )
	postscript? ( app-text/ghostscript-gpl )
	wmf? ( media-libs/libwmf )
"

DEPEND="${COMMON_DEPEND}
	dev-libs/boost:=
	>=dev-util/intltool-0.29
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-0.48.0-spell.patch"
	"${FILESDIR}/${PN}-0.48.2-libwpg.patch"
	"${FILESDIR}/${PN}-0.48.3.1-desktop.patch"
	"${FILESDIR}/${PN}-0.48.4-epython.patch"
	"${FILESDIR}/${PN}-0.48.4-automake-1.13.patch"
	"${FILESDIR}/${PN}-0.48.4-gc74-configure.patch"
	"${FILESDIR}/${PN}-0.48.4-poppler-0.29.0.patch"
)

S=${WORKDIR}/${MY_P}

src_prepare() {
	default

	sed -i "s#@EPYTHON@#${EPYTHON}#" \
		src/extension/implementation/script.cpp || die

	eautoreconf

	# bug 421111
	python_fix_shebang share/extensions
}

src_configure() {
	# aliasing unsafe wrt #310393
	append-flags -fno-strict-aliasing

	econf \
		$(use_enable nls) \
		$(use_enable lcms) \
		--without-perl \
		--enable-poppler-cairo \
		$(use_with gnome gnome-vfs) \
		$(use_with inkjar) \
		$(use_with spell gtkspell) \
		$(use_with spell aspell)
}

src_compile() {
	emake AR="$(tc-getAR)"
}

src_install() {
	default

	prune_libtool_files
	python_optimize "${ED}"/usr/share/${PN}/extensions
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}
