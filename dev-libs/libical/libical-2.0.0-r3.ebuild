# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake

DESCRIPTION="An implementation of basic iCAL protocols"
HOMEPAGE="https://github.com/libical/libical"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( MPL-1.0 LGPL-2.1 )"
SLOT="0/2"
KEYWORDS="~*"

IUSE="doc examples static-libs"

RDEPEND="
	dev-libs/icu:=
"
DEPEND="${RDEPEND}
	dev-lang/perl
"

PATCHES=(
	"${FILESDIR}"/${PN}-2.0.0-libical.pc-set-full-version.patch
	"${FILESDIR}"/${PN}-2.0.0-libical.pc-icu-remove-full-paths.patch
	"${FILESDIR}"/${PN}-2.0.0-libical.pc-icu-move-to-requires.patch
	"${FILESDIR}"/${PN}-2.0.0-libical.pc-fix-libdir-location.patch
	"${FILESDIR}"/${PN}-2.0.0-tests.patch #bug 532296
)

src_configure() {
	use static-libs || mycmakeargs+=( -DSHARED_ONLY=ON )
	cmake_src_configure
}

src_test() {
	local myctestargs=(
		-j1
	)
	cmake_src_test
}

src_install() {
	cmake_src_install

	if use examples; then
		rm examples/CMakeLists.txt || die
		dodoc -r examples
	fi
}
