# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME_ORG_MODULE="gtk-doc"

inherit gnome.org

DESCRIPTION="Automake files from gtk-doc"
HOMEPAGE="https://wiki.gnome.org/DocumentationProject/GtkDoc"

LICENSE="GPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="*"

# This ebuild doesn't even compile anything, causing tests to fail when updating (bug #316071)
RESTRICT="test"

RDEPEND="!<dev-util/gtk-doc-${GNOME_ORG_PVP}"
PDEPEND="virtual/pkgconfig"

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	insinto /usr/share/aclocal
	doins buildsystems/autotools/gtk-doc.m4
}
