# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_5,3_6,3_7,3_8} )

inherit cmake-utils python-any-r1

DESCRIPTION="An implementation of basic iCAL protocols"
HOMEPAGE="https://github.com/libical/libical"
SRC_URI="https://github.com/${PN}/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="|| ( MPL-2.0 LGPL-2.1 )"
SLOT="0/3"
KEYWORDS="~*"

IUSE="berkdb doc examples glib static-libs test"

BDEPEND="
	dev-lang/perl
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
	test? ( ${PYTHON_DEPS} )
"
DEPEND="
	dev-libs/icu:=
	berkdb? ( sys-libs/db:= )
	glib? (
		dev-libs/glib:2
		dev-libs/libxml2:2
	)
"
RDEPEND="${DEPEND}
	sys-libs/timezone-data
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.0.4-tests.patch
	"${FILESDIR}"/${PN}-3.0.5-pkgconfig-libdir.patch
	"${FILESDIR}"/${PN}-3.0.5-fix-lots-of-params.patch
)

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	cmake-utils_src_prepare
	use examples || cmake_comment_add_subdirectory examples
}

src_configure() {
	local mycmakeargs=(
		-DICAL_GLIB=$(usex glib)
		-DICAL_GLIB_VAPI=OFF
		-DGOBJECT_INTROSPECTION=OFF
		$(cmake-utils_use_find_package berkdb BDB)
		-DICAL_BUILD_DOCS=$(usex doc)
		-DSHARED_ONLY=$(usex !static-libs)
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	use doc && cmake-utils_src_compile docs
}

src_test() {
	local myctestargs=(
		-E "(icalrecurtest|icalrecurtest-r)" # bug 660282
	)

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
