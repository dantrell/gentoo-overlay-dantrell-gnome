# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"
VALA_MAX_API_VERSION="0.40"

inherit gnome2 vala meson

DESCRIPTION="View information about use of system resources, like memory and disk space."
HOMEPAGE="https://wiki.gnome.org/Apps/Usage"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.38
	>=dev-libs/gobject-introspection-1:=
	>=x11-libs/gtk+-3.20.10
	>=gnome-base/libgtop-2.34.2
"
DEPEND="${RDEPEND}
	$(vala_depend)
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}
