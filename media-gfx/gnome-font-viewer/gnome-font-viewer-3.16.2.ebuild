# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Font viewer for GNOME"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-font-viewer"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE=""

# Rebuild between GLib slot changes to prevent "--usepkg" merge conflicts
RDEPEND="
	>=dev-libs/glib-2.35.1:2=
	gnome-base/gnome-desktop:3=
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	>=media-libs/harfbuzz-0.9.9
	>=x11-libs/gtk+-3.11.4:3
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	virtual/pkgconfig
"
