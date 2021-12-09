# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit cmake xdg-utils

DESCRIPTION="Cross-distro effort for providing metadata for software in the Linux ecosystem"
HOMEPAGE="https://www.freedesktop.org/wiki/Distributions/AppStream/"
SRC_URI="https://www.freedesktop.org/software/appstream/releases/AppStream-${PV}.tar.xz"

LICENSE="LGPL-2.1+ GPL-2+"
# check as_api_level
SLOT="0/4"
KEYWORDS="*"

IUSE="doc qt5 test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.36:2
	dev-libs/libxml2:2
	dev-libs/libyaml
	dev-libs/xapian
	dev-libs/gobject-introspection:=
	qt5? ( dev-qt/qtcore:5 )
"
DEPEND="${RDEPEND}
	test? ( qt5? ( dev-qt/qttest:5 ) )
"
BDEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.5
	app-text/xmlto
	dev-util/itstool
	sys-devel/gettext
"

S="${WORKDIR}/AppStream-${PV}"

src_prepare() {
	cmake_src_prepare

	if ! use test; then
		pushd qt > /dev/null || die
		cmake_comment_add_subdirectory tests
		popd > /dev/null || die
	fi
}

src_configure() {
	xdg_environment_reset

	local mycmakeargs=(
		-DDEBIAN_DEP11=OFF
		-DL18N=ON
		-DVAPI=OFF
		-DMAINTAINER=OFF
		-DDOCUMENTATION=OFF
		-DINSTALL_PREBUILT_DOCS=$(usex doc)
		-DQT=$(usex qt5)
	)

	cmake_src_configure
}
