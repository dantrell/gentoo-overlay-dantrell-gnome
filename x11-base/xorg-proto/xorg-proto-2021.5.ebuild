# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python{3_10,3_11,3_12} )

MY_PN="${PN/xorg-/xorg}"
MY_P="${MY_PN}-${PV}"

inherit meson python-any-r1

DESCRIPTION="X.Org combined protocol headers"
HOMEPAGE="https://gitlab.freedesktop.org/xorg/proto/xorgproto"
SRC_URI="https://xorg.freedesktop.org/archive/individual/proto/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

BDEPEND="
	test? (
		$(python_gen_any_dep '
			dev-python/python-libevdev[${PYTHON_USEDEP}]
		')
	)
"

S="${WORKDIR}/${MY_P}"

python_check_deps() {
	python_has_version "dev-python/python-libevdev[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_install() {
	meson_src_install

	mv "${ED}"/usr/share/doc/{xorgproto,${P}} || die
}
