# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2-live

DESCRIPTION="A graphical user interface to view and monitor system log files"
HOMEPAGE="https://help.gnome.org/users/gnome-system-log/"
EGIT_COMMIT="4b071909a0ca38a73a9cc5b287ffc2b0a744566b"

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
	eapply "${FILESDIR}"/${PN}-9999-update-version-information.patch

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--enable-zlib
}
