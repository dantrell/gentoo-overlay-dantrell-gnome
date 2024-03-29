# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org meson

DESCRIPTION="Effects for Cheese, the webcam video and picture application"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeVideoEffects"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# This ebuild does not install any binaries
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
BDEPEND="
	>=dev-util/intltool-0.40.0
	>=sys-devel/gettext-0.17
"
