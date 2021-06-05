# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_8,3_9,3_10} )

inherit gnome.org python-any-r1 meson

DESCRIPTION="Build infrastructure and utilities for GNOME C++ bindings"
HOMEPAGE="https://www.gtkmm.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"

BDEPEND="${PYTHON_DEPS}"

src_prepare() {
	default

	# Include project version in docdir name
	sed -i -e "s:^install_docdir.*:& + '-' + meson.project_version():" meson.build || die
}
