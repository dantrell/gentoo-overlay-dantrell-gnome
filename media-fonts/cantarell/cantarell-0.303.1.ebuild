# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME_ORG_MODULE="${PN}-fonts"

inherit font gnome.org meson

DESCRIPTION="Default fontset for GNOME Shell"
HOMEPAGE="https://wiki.gnome.org/Projects/CantarellFonts"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="*"

IUSE=""

# This ebuild does not install any binaries
RESTRICT="binchecks strip"

BDEPEND="
	>=sys-devel/gettext-0.20
	virtual/pkgconfig
"

# Font eclass settings
FONT_CONF=("${S}/fontconfig/31-cantarell.conf")
FONT_S="${S}/prebuilt"
FONT_SUFFIX="otf"

src_prepare() {
	# Leave prebuilt font installation to font.eclass
	sed -e "/subdir('prebuilt')/d" -i meson.build || die

	default
}

src_configure() {
	local emesonargs=(
		-Dfontsdir=${FONTDIR}
		-Duseprebuilt=true
		-Dbuildappstream=true
		-Dbuildstatics=false
		-Dbuildvf=true
	)
	meson_src_configure
}

src_install() {
	font_src_install
	meson_src_install
}
