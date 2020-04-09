# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit git-r3 meson

DESCRIPTION="Simple and modern eBook viewer"
HOMEPAGE="https://johnfactotum.github.io/foliate/"
EGIT_REPO_URI="https://github.com/johnfactotum/foliate"
EGIT_COMMIT="afce2538b1ed5c386d11c39541bd1cbc7acc0149"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	dev-libs/gjs
	net-libs/webkit-gtk
"
DEPEND="
	${RDEPEND}
	dev-util/meson
	sys-devel/gettext
"
