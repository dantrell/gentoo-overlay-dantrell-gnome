# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"

inherit eutils gnome2-live

DESCRIPTION="A graphical user interface to view and monitor system log files"
HOMEPAGE="https://help.gnome.org/users/gnome-system-log/"
EGIT_COMMIT="0b0754505dec9d52e14c8e77b019d44182b561e9"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE=""

COMMON_DEPEND="
	>=dev-libs/glib-2.31:2
	sys-libs/zlib:=
	>=x11-libs/gtk+-3.11.4:3
	x11-libs/pango
"
# ${PN} was part of gnome-utils before 3.4
RDEPEND="
	${COMMON_DEPEND}
	gnome-base/gsettings-desktop-schemas
	!<gnome-extra/gnome-utils-3.4
"

DEPEND="
	${COMMON_DEPEND}
	app-text/yelp-tools
	>=dev-util/intltool-0.40
	dev-util/itstool
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

src_prepare() {
	epatch "${FILESDIR}"/${P}-update-version-information.patch

	epatch_user

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--enable-zlib
}
