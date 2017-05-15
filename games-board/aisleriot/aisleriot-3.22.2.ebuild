# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome2

DESCRIPTION="A collection of solitaire card games for GNOME"
HOMEPAGE="https://wiki.gnome.org/action/show/Apps/Aisleriot"

LICENSE="GPL-3 LGPL-3 FDL-1.1"
SLOT="0"
KEYWORDS="*"

IUSE="debug extra gnome +sound"

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
	gnome? ( >=gnome-base/gconf-2.0:2 )
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

src_prepare() {
	# Fix SVG detection and usage
	eapply "${FILESDIR}"/${PN}-3.22.0-detect-svg.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	local myconf=()

	if use extra ; then
		myconf+=(
			--with-card-theme-formats=all
			--with-pysol-card-theme-path="${EPREFIX}${GAMES_DATADIR}"/pysolfc
			--with-kde-card-theme-path="${EPREFIX}"/usr/share/apps/carddecks
		)
	else
		myconf+=( --with-card-theme-formats=svg,fixed )
	fi

	if use gnome; then
		myconf+=(
			--with-platform=gnome
			--with-help-method=ghelp
		)
	else
		myconf+=(
			--with-platform=gtk-only
			--with-help-method=library
		)
	fi

	gnome2_src_configure \
		--with-gtk=3.0 \
		--with-guile=2.0 \
		$(usex debug --enable-debug=yes --enable-debug=minimum) \
		$(use_enable sound) \
		${myconf[@]}
}

pkg_postinst() {
	gnome2_pkg_postinst

	elog "Aisleriot can use additional card themes from games-board/pysolfc"
	elog "and kde-base/libkdegames. Enable through the 'extra' USE flag."
}
