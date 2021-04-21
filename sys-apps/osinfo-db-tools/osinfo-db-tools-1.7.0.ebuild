# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python{3_6,3_7,3_8,3_9} )

inherit gnome2 meson python-any-r1

DESCRIPTION="Tools for managing the osinfo database"
HOMEPAGE="https://libosinfo.org/"
SRC_URI="https://releases.pagure.org/libosinfo/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

# Blocker on old libosinfo as osinfo-db-validate was part of it before
RDEPEND="
	>=dev-libs/glib-2.44:2
	>=dev-libs/libxml2-2.6.0
	>=app-arch/libarchive-3.0.0:=
	dev-libs/json-glib
	net-libs/libsoup:2.4
	!<sys-libs/libosinfo-1.0.0
"
# perl dep is for pod2man (and syntax check but only in git, but configure check exists in release)
# libxslt is checked for in configure.ac, but never used in 1.1.0
DEPEND="${RDEPEND}
	>=dev-libs/libxslt-1.0.0
	virtual/pkgconfig
	>=sys-devel/gettext-0.19.8
	dev-lang/perl
	test? (
		$(python_gen_any_dep '
			dev-python/pytest[${PYTHON_USEDEP}]
			dev-python/requests[${PYTHON_USEDEP}]
		')
	)
"

python_check_deps() {
	use test && \
		has_version "dev-python/pytest[${PYTHON_USEDEP}]" && \
		has_version "dev-python/requests[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}
