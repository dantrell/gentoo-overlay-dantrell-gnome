# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME2_LA_PUNT="yes"
GNOME_TARBALL_SUFFIX="gz"

inherit autotools flag-o-matic gnome2 libtool multilib-minimal portability

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2.1+"
SLOT="1"
KEYWORDS="*"

IUSE="+debug hardened static-libs"

MULTILIB_CHOST_TOOLS=(/usr/bin/glib-config)

src_prepare() {
	eapply "${FILESDIR}"/${PN}-1.2.10-automake.patch
	eapply "${FILESDIR}"/${PN}-1.2.10-m4.patch
	eapply "${FILESDIR}"/${PN}-1.2.10-configure-LANG.patch #133679

	# Allow glib to build with gcc-3.4.x #47047
	eapply "${FILESDIR}"/${PN}-1.2.10-gcc34-fix.patch

	# Fix for -Wl,--as-needed (bug #133818)
	eapply "${FILESDIR}"/${PN}-1.2.10-r1-as-needed.patch

	# build failure with automake-1.13
	eapply "${FILESDIR}"/${PN}-1.2.10-automake-1.13.patch

	use ppc64 && use hardened && replace-flags -O[2-3] -O1
	sed -i "/libglib_la_LDFLAGS/i libglib_la_LIBADD = $(dlopen_lib)" Makefile.am || die

	rm -f acinclude.m4 #168198

	mv configure.in configure.ac || die

	eautoreconf
	gnome2_src_prepare
}

multilib_src_configure() {
	append-cflags -std=gnu89

	ECONF_SOURCE="${S}" \
	gnome2_src_configure \
		--with-threads=posix \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable static-libs static)
}

multilib_src_install() {
	gnome2_src_install

	chmod 755 "${ED}"/usr/$(get_libdir)/libgmodule-1.2.so.* || die
}

multilib_src_install_all() {
	einstalldocs
	docinto html
	dodoc -r docs/.
}
