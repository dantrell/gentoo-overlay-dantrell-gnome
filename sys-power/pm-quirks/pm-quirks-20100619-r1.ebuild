# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Video Quirks database for pm-utils"
HOMEPAGE="https://pm-utils.freedesktop.org/"
SRC_URI="https://pm-utils.freedesktop.org/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

S="${WORKDIR}"

src_install() {
	insinto /usr/$(get_libdir)/pm-utils
	doins -r video-quirks
}
