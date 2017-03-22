# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Effects for Cheese, the webcam video and picture application"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeVideoEffects"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

# This ebuild does not install any binaries
RESTRICT="binchecks strip"

RDEPEND=""
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40.0
	>=sys-devel/gettext-0.17
"

