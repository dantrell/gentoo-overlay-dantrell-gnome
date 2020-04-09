# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson

DESCRIPTION="Effects for Cheese, the webcam video and picture application"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeVideoEffects"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"

IUSE=""

# This ebuild does not install any binaries
RESTRICT="binchecks strip"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/meson-0.50.0
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"
