# Distributed under the terms of the GNU General Public License v2

EAPI="7"

XORG_DOC=doc
XORG_MULTILIB=yes

inherit xorg-3

DESCRIPTION="X.Org Xi library"
KEYWORDS="*"

RDEPEND="
	>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
	>=x11-libs/libXext-1.3.2[${MULTILIB_USEDEP}]
	>=x11-libs/libXfixes-5.0.1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	x11-base/xorg-proto"

src_configure() {
	local XORG_CONFIGURE_OPTIONS=(
		$(use_enable doc specs)
		$(use_with doc xmlto)
		$(use_with doc asciidoc)
		--without-fop
	)
	xorg-3_src_configure
}
