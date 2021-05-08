# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME_TARBALL_SUFFIX="bz2"

inherit autotools gnome2

DESCRIPTION="Typesafe callback system for standard C++"
HOMEPAGE="https://libsigcplusplus.github.io/libsigcplusplus/
	https://github.com/libsigcplusplus/libsigcplusplus"

LICENSE="GPL-2 LGPL-2.1+"
SLOT="1.2"
KEYWORDS="*"

IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/m4
"

src_prepare() {
	# fixes bug #219041
	sed -e 's:ACLOCAL_AMFLAGS = -I $(srcdir)/scripts:ACLOCAL_AMFLAGS = -I scripts:' \
		-i Makefile.{in,am}

	# fixes bug #469698
	sed -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:g' -i configure.in || die

	# Fix duplicated file installation, bug #346949
	eapply "${FILESDIR}"/${PN}-1.2.7-fix-install.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--enable-maintainer-mode \
		--enable-threads
}
