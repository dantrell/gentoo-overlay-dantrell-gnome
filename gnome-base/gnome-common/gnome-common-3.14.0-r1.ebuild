# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit gnome.org

DESCRIPTION="Common files for development of Gnome packages"
HOMEPAGE="https://git.gnome.org/browse/gnome-common"

LICENSE="GPL-3"
SLOT="3"
KEYWORDS="*"

IUSE="+autoconf-archive"

RDEPEND="autoconf-archive? ( >=sys-devel/autoconf-archive-2015.02.04 )
	!autoconf-archive? ( !>=sys-devel/autoconf-archive-2015.02.04 )
"
DEPEND=""

src_install() {
	default
	if use autoconf-archive; then
		# do not install macros owned by autoconf-archive, bug #540138
		rm "${ED}"/usr/share/aclocal/ax_{check_enable_debug,code_coverage}.m4 || die "removing macros failed"
	fi
	mv doc-build/README README.doc-build || die "renaming doc-build/README failed"
	dodoc ChangeLog README*
}
