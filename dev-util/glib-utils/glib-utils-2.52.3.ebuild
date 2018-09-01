# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Build utilities for GLib using projects"
HOMEPAGE="https://www.gtk.org/"

LICENSE="LGPL-2.1+"
SLOT="0" # /usr/bin utilities that can't be parallel installed by their nature
KEYWORDS="*"

IUSE=""

RDEPEND="dev-libs/glib:2"
