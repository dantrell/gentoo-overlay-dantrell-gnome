# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
VALA_USE_DEPEND="vapigen"

inherit cmake python-any-r1 vala

DESCRIPTION="Implementation of basic iCAL protocols"
HOMEPAGE="https://github.com/libical/libical"
SRC_URI="https://github.com/${PN}/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="|| ( MPL-2.0 LGPL-2.1 )"
SLOT="0/3"
KEYWORDS="*"

IUSE="berkdb doc examples introspection static-libs test vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

COMMON_DEPEND="
	dev-libs/icu:=
	berkdb? ( sys-libs/db:= )
	introspection? ( dev-libs/glib:2 )
"
DEPEND="${COMMON_DEPEND}
	introspection? ( dev-libs/libxml2:2 )
"
RDEPEND="${COMMON_DEPEND}
	sys-libs/timezone-data
"
BDEPEND="
	dev-lang/perl
	virtual/pkgconfig
	doc? (
		app-text/doxygen[dot]
		introspection? ( dev-util/gtk-doc )
	)
	introspection? ( dev-libs/gobject-introspection:= )
	test? (
		${PYTHON_DEPS}
		introspection? ( $(python_gen_any_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]') )
	)
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.0.4-tests.patch
	"${FILESDIR}"/${PN}-3.0.11-pkgconfig-libdir.patch
)

python_check_deps() {
	python_has_version "dev-python/pygobject:3[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare
	use examples || cmake_comment_add_subdirectory examples
	use vala && vala_src_prepare
}

src_configure() {
	local mycmakeargs=(
		$(cmake_use_find_package berkdb BDB)
		-DICAL_BUILD_DOCS=$(usex doc)
		-DICAL_GLIB=$(usex introspection)
		-DGOBJECT_INTROSPECTION=$(usex introspection)
		-DSHARED_ONLY=$(usex !static-libs)
		-DLIBICAL_BUILD_TESTING=$(usex test)
		-DICAL_GLIB_VAPI=$(usex vala)
	)
	if use vala; then
		mycmakeargs+=(
			-DVALAC="${VALAC}"
			-DVAPIGEN="${VAPIGEN}"
		)
	fi
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	use doc && cmake_src_compile docs
}

src_test() {
	local myctestargs=(
		-E "(icalrecurtest|icalrecurtest-r)" # bug 660282
	)

	cmake_src_test
}

src_install() {
	use doc && local HTML_DOCS=( "${BUILD_DIR}"/apidocs/html/. )

	cmake_src_install

	if use examples; then
		rm examples/CMakeLists.txt || die
		dodoc -r examples
	fi
}
