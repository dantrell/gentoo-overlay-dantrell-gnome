# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GNOME_ORG_MODULE="gtk-doc"

inherit gnome.org

DESCRIPTION="Automake files from gtk-doc"
HOMEPAGE="http://www.gtk.org/gtk-doc/"

LICENSE="GPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="*"

IUSE=""

# This ebuild doesn't even compile anything, causing tests to fail when updating (bug #316071)
RESTRICT="test"

RDEPEND=">=dev-lang/perl-5.6"
DEPEND="${RDEPEND}
	!<dev-util/gtk-doc-${GNOME_ORG_PVP}
"
# pkg-config is used by gtkdoc-rebase at runtime
# PDEPEND to avoid circular deps, bug 368301
PDEPEND="virtual/pkgconfig"

src_configure() {
	# Duplicate autoconf checks so we don't have to call configure
	local PERL=$(type -P perl)

	test -n "${PERL}" || die "Perl not found!"
	"${PERL}" -e "require v5.6.0" || die "perl >= 5.6.0 is required for gtk-doc"

	# Replicate AC_SUBST
	sed -e "s:@PERL@:${PERL}:g" -e "s:@VERSION@:${PV}:g" \
		"${S}/gtkdoc-rebase.in" > "${S}/gtkdoc-rebase" || die "sed failed!"
}

src_compile() {
	:
}

src_install() {
	dobin gtkdoc-rebase

	insinto /usr/share/aclocal
	doins gtk-doc.m4
}
