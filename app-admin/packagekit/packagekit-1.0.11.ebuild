# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="PackageKit Package Manager interface (meta package)"
HOMEPAGE="http://www.packagekit.org/"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="*"

IUSE="gtk qt4"

RDEPEND="gtk? ( ~app-admin/packagekit-gtk-${PV} )
	qt4? ( =app-admin/packagekit-qt4-0.8* )"

DEPEND="${RDEPEND}"
