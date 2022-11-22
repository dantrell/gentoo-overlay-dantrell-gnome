# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2

DESCRIPTION="Common files for development of Gnome packages"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-common"

LICENSE="GPL-3"
SLOT="3"
KEYWORDS="*"

RDEPEND=">=sys-devel/autoconf-archive-2015.02.04"

src_install() {
	default

	# do not install macros owned by autoconf-archive, bug #540138
	rm "${ED}"/usr/share/aclocal/ax_{check_enable_debug,code_coverage}.m4 || die "removing macros failed"
}
