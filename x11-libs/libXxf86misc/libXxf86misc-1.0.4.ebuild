# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit xorg-2

DESCRIPTION="X.Org Xxf86misc library"

KEYWORDS="*"

IUSE=""

RDEPEND="
	<x11-base/xorg-proto-2020.0
	x11-libs/libX11
	x11-libs/libXext
"
DEPEND="${RDEPEND}"
