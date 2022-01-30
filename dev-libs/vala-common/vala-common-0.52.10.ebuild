# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME_ORG_MODULE="vala"

inherit gnome.org

DESCRIPTION="Build infrastructure for packages that use Vala"
HOMEPAGE="https://wiki.gnome.org/Projects/Vala"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

RDEPEND=""
DEPEND=""
BDEPEND=""

src_configure() { :; }

src_compile() { :; }

src_install() {
	insinto /usr/share/aclocal
	doins vala.m4 vapigen/vapigen.m4
	insinto /usr/share/vala
	doins vapigen/Makefile.vapigen
}
