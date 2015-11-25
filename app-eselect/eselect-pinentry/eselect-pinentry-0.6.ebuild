# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Manage /usr/bin/pinentry symlink"
HOMEPAGE="https://www.gentoo.org/proj/en/eselect/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND=">=app-eselect/eselect-lib-bin-symlink-0.1.1"

S=${FILESDIR}

src_install() {
	insinto /usr/share/eselect/modules
	newins pinentry.eselect-${PV} pinentry.eselect
}
