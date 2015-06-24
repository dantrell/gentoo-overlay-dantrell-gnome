# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"

inherit eutils gnome2-live

DESCRIPTION="System log viewer for GNOME"
HOMEPAGE="https://live.gnome.org/GnomeUtils"
EGIT_COMMIT="cf5ecade34dab876861122adfa6b8469b145c3e6"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"
IUSE=""
KEYWORDS="*"

COMMON_DEPEND="
	>=dev-libs/glib-2.31:2
	sys-libs/zlib:=
	>=x11-libs/gtk+-3.9.11:3
	x11-libs/pango
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gsettings-desktop-schemas
	!<gnome-extra/gnome-utils-3.4"
# ${PN} was part of gnome-utils before 3.4

DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	app-text/yelp-tools
	virtual/pkgconfig
"

src_prepare() {
	epatch "${FILESDIR}"/${P}-update-version-information.patch

	epatch_user

	./autogen.sh || die

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--enable-zlib \
		ITSTOOL=$(type -P true)
}

pkg_postinst() {
	ewarn "While this ebuild is tied to a specific git commit, instability can still occur"
}
