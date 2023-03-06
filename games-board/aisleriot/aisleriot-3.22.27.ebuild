# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="A collection of solitaire card games for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Aisleriot"
SRC_URI="https://gitlab.gnome.org/GNOME/${PN}/-/archive/${PV}/${P}.tar.bz2"

LICENSE="GPL-3 LGPL-3 FDL-1.1"
SLOT="0"
KEYWORDS="~*"

IUSE="debug doc extra gconf gnome +sound"

COMMON_DEPEND="
	>=dev-libs/glib-2.32:2
	>=dev-scheme/guile-2.0.0[deprecated,regex]
	<dev-scheme/guile-2.1.0
	>=gnome-base/librsvg-2.32:2
	>=x11-libs/cairo-1.10
	>=x11-libs/gtk+-3.4:3
	extra? (
		games-board/pysolfc
		kde-base/libkdegames
	)
	gconf? ( >=gnome-base/gconf-2.0:2 )
	sound? ( >=media-libs/libcanberra-0.26[gtk3] )
"
DEPEND="${COMMON_DEPEND}
	app-arch/gzip
	dev-libs/libxml2
	>=dev-util/intltool-0.40.4
	dev-util/itstool
	sys-apps/lsb-release
	>=sys-devel/gettext-0.12
	virtual/pkgconfig
	gnome? ( app-text/docbook-xml-dtd:4.3 )
"

src_configure() {
	local emesonargs=(
		-Dbinreloc=false
		$(meson_use debug dbg)
		$(meson_use debug dbgui)
		$(meson_use doc docs)
		$(meson_use gconf)
		-Dguile="auto"
		$(meson_use sound)
	)

	if use extra ; then
		emesonargs+=(
			-Dtheme_fixed=true
			-Dtheme_kde=true
			-Dtheme_kde_path="${EPREFIX}"/usr/share/apps/carddecks
			-Dtheme_pysol=true
			-Dtheme_pysol_path="${EPREFIX}${GAMES_DATADIR}"/pysolfc
			-Dtheme_svg_qtsvg=true
			-Dtheme_svg_rsvg=true
		)
	else
		emesonargs+=(
			-Dtheme_fixed=true
			-Dtheme_kde=false
			-Dtheme_pysol=false
			-Dtheme_svg_qtsvg=false
			-Dtheme_svg_rsvg=true
		)
	fi

	if use gnome ; then
		emesonargs+=( -Dhelp_method="ghelp" )
	else
		emesonargs+=( -Dhelp_method="library" )
	fi

	meson_src_configure
}

pkg_postinst() {
	gnome2_pkg_postinst

	elog "Aisleriot can use additional card themes from games-board/pysolfc"
	elog "and kde-base/libkdegames. Enable through the 'extra' USE flag."
}
