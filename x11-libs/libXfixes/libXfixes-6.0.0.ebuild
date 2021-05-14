# Distributed under the terms of the GNU General Public License v2

EAPI="7"

XORG_DOC=doc
XORG_MULTILIB=yes

inherit xorg-3

DESCRIPTION="X.Org Xfixes library"

KEYWORDS="~*"

RDEPEND="
	>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	>=x11-base/xorg-proto-2021.4"
