# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2

DESCRIPTION="Symbolic icons for GNOME default icon theme"
HOMEPAGE="https://gitlab.gnome.org/Archive/gnome-icon-theme-symbolic"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

# This ebuild does not install any binaries
RESTRICT="binchecks strip"

DEPEND=">=x11-themes/hicolor-icon-theme-0.10"
RDEPEND="${DEPEND}
	gnome-base/librsvg
"
BDEPEND="
	>=x11-misc/icon-naming-utils-0.8.7
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		--enable-icon-mapping \
		GTK_UPDATE_ICON_CACHE=$(type -P true)
}
