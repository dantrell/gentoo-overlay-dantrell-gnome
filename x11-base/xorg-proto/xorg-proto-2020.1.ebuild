# Distributed under the terms of the GNU General Public License v2

EAPI="8"

MY_PN="${PN/xorg-/xorg}"
MY_P="${MY_PN}-${PV}"

inherit meson

DESCRIPTION="X.Org combined protocol headers"
HOMEPAGE="https://gitlab.freedesktop.org/xorg/proto/xorgproto"
SRC_URI="https://xorg.freedesktop.org/archive/individual/proto/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}/${MY_P}"
