# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2

DESCRIPTION="Extra GNOME icons for specific devices and file types"
HOMEPAGE="https://gitlab.gnome.org/Archive/gnome-icon-theme-extras"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

# This ebuild does not install any binaries
RESTRICT="binchecks strip"

RDEPEND=">=x11-themes/hicolor-icon-theme-0.10"
DEPEND="${RDEPEND}"
BDEPEND="
	>=x11-misc/icon-naming-utils-0.8.7
	virtual/pkgconfig"


src_prepare() {
	gnome2_src_prepare

	# Always use pre-rendered icons
	sed -e 's/"x$allow_rendering" = "xyes"/"x$allow_rendering" = "xdonotwant"/' \
		-i configure || die
}

src_configure() {
	gnome2_src_configure --enable-icon-mapping
}
