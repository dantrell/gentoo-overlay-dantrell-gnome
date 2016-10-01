# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome2

DESCRIPTION="A simplistic personal task manager"
HOMEPAGE="https://wiki.gnome.org/Apps/Todo"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RESTRICT="mirror"

RDEPEND="
	>=dev-libs/glib-2.43.4:2
	>=dev-libs/libical-0.43
	>=gnome-extra/evolution-data-server-3.17.1[gtk]
	>=net-libs/gnome-online-accounts-3.2
	>=x11-libs/gtk+-3.16:3
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40.6
	dev-libs/appstream-glib
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	# From Arch Linux:
	# 	https://git.archlinux.org/svntogit/packages.git/commit/?id=851b201268186ac89b1da6b1355775bee8167144
	eapply "${FILESDIR}"/${PN}-3.19.91-correct-linking-order.patch

	eautoreconf
	gnome2_src_prepare
}
