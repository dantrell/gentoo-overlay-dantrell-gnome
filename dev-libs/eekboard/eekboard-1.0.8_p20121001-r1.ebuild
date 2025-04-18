# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
VALA_USE_DEPEND="vapigen"

inherit autotools gnome2-utils python-any-r1 vala vcs-snapshot virtualx xdg

DESCRIPTION="An easy to use virtual keyboard toolkit"
HOMEPAGE="https://github.com/ueno/eekboard"
SRC_URI="https://github.com/ueno/${PN}/archive/e212262f29e022bdf7047861263ceea0c373e916.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

IUSE="doc +introspection libcanberra static-libs +vala +xtest"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

RDEPEND="app-accessibility/at-spi2-core
	dev-libs/glib:2
	dev-libs/libcroco
	virtual/libintl
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxklavier
	x11-libs/pango
	introspection? ( dev-libs/gobject-introspection:= )
	libcanberra? ( media-libs/libcanberra[gtk3(+)] )
	vala? ( $(vala_depend) )
	xtest? ( x11-libs/libXtst )"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}
	dev-util/gtk-doc
	dev-build/gtk-doc-am
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-python-3.patch
	"${FILESDIR}"/${PN}-vala.patch
)

src_prepare() {
	use vala && vala_src_prepare
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable doc gtk-doc) \
		$(use_enable introspection) \
		$(use_enable libcanberra) \
		$(use_enable static-libs static) \
		$(use_enable vala) \
		$(use_enable xtest)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}

src_test() {
	virtx default
}

pkg_preinst() {
	xdg_pkg_preinst
	gnome2_schemas_savelist
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
