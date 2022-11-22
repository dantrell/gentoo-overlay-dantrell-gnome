# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit meson

DESCRIPTION="Flatpak portal library"
HOMEPAGE="https://github.com/flatpak/libportal"
SRC_URI="https://github.com/flatpak/libportal/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-libs/glib:2

	!sys-libs/libportal
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/gtk-doc
"

src_configure() {
	local emesonargs=(
		-Dbuild-portal-test=false
	)
	meson_src_configure
}
