# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="An easy-to-use application that will help you to discover what to cook today"
HOMEPAGE="https://wiki.gnome.org/Apps/Recipes"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+archive +sound +spell"

RDEPEND="
	>=dev-libs/glib-2.42
	media-libs/libcanberra
	net-libs/libsoup:2.4
	>=x11-libs/gtk+-3.22:3
	>=dev-libs/json-glib-1
	>=net-libs/rest-0.7
	>=net-libs/gnome-online-accounts-1
	archive? ( app-arch/gnome-autoar )
	sound? ( media-libs/libcanberra )
	spell? ( app-text/gspell )
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-D autoar=$(usex archive yes no)
		-D gspell=$(usex spell yes no)
		-D canberra=$(usex sound yes no)
	)
	meson_src_configure
}
