# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson

DESCRIPTION="Build infrastructure and utilities for GNOME C++ bindings"
HOMEPAGE="https://www.gtkmm.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"

IUSE=""

RDEPEND=""
DEPEND=""

src_prepare() {
	default

	# Include project version in docdir name
	sed -i -e "s:^install_docdir.*:& + '-' + meson.project_version():" meson.build || die
}
