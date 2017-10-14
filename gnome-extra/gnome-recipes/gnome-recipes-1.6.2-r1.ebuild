# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="An easy-to-use application that will help you to discover what to cook today"
HOMEPAGE="https://wiki.gnome.org/Apps/Recipes"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE="+spell +archive +sound"

DEPEND="
	>=dev-util/meson-0.36
	>=sys-devel/gettext-0.19.7
	spell? ( app-text/gspell )
	archive? ( app-arch/gnome-autoar )
	sound? ( media-libs/libcanberra )
	>=dev-libs/glib-2.42
	>=x11-libs/gtk+-3.22
"

src_prepare() {
	cd "${S}"/subprojects
	rm -rf libgd
	git clone https://git.gnome.org/browse/libgd
	cd "${S}"
	rm -rf build

	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D enable-autoar=$(usex archive yes no)
		-D enable-gspell=$(usex spell yes no)
		-D enable-canberra=$(usex sound yes no)
	)
	meson_src_configure
}
