# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python{3_5,3_6,3_7,3_8} )

inherit cmake-utils python-any-r1

DESCRIPTION="An implementation of basic iCAL protocols"
HOMEPAGE="https://github.com/libical/libical"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( MPL-2.0 LGPL-2.1 )"
SLOT="0/3"
KEYWORDS="~*"

IUSE="berkdb doc examples glib introspection static-libs test"

COMMON_DEPEND="
	dev-libs/icu:=
	berkdb? ( sys-libs/db:= )
	glib? (
		dev-libs/glib:2
		dev-libs/libxml2:2
	)
	introspection? ( dev-libs/gobject-introspection:= )
"
DEPEND="${COMMON_DEPEND}
	dev-lang/perl
	doc? ( app-doc/doxygen )
	test? ( ${PYTHON_DEPS} )
"
RDEPEND="${COMMON_DEPEND}
	sys-libs/timezone-data
"

PATCHES=( "${FILESDIR}"/${PN}-3.0.1-pkgconfig-libdir.patch )

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	cmake-utils_src_prepare

	use doc || cmake_comment_add_subdirectory doc
	use examples || cmake_comment_add_subdirectory examples
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_find_package berkdb BDB)
		-DICAL_GLIB=$(usex glib)
		-DGOBJECT_INTROSPECTION=$(usex introspection)
		-DSHARED_ONLY=$(usex !static-libs)
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	use doc && cmake-utils_src_compile docs
}

src_test() {
	local myctestargs=( -j1 )
	cmake-utils_src_test
}

src_install() {
	use doc && HTML_DOCS=( "${BUILD_DIR}"/apidocs/html/. )
	cmake-utils_src_install

	if use examples; then
		rm examples/CMakeLists.txt || die
		dodoc -r examples
	fi
}
