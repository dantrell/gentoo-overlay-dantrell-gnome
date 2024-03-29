# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 flag-o-matic multilib-minimal

DESCRIPTION="Typesafe callback system for standard C++"
HOMEPAGE="https://libsigcplusplus.github.io/libsigcplusplus/
	https://github.com/libsigcplusplus/libsigcplusplus"

LICENSE="LGPL-2.1+"
SLOT="2/4"
KEYWORDS="*"

IUSE="gtk-doc static-libs test"

RESTRICT="!test? ( test )"

RDEPEND=""
DEPEND="sys-devel/m4"
# Needs mm-common for eautoreconf

src_prepare() {
	# don't waste time building examples
	sed -i 's|^\(SUBDIRS =.*\)examples\(.*\)$|\1\2|' \
		Makefile.am Makefile.in || die "sed examples failed"

	# don't waste time building tests unless USE=test
	if ! use test ; then
		sed -i 's|^\(SUBDIRS =.*\)tests\(.*\)$|\1\2|' \
			Makefile.am Makefile.in || die "sed tests failed"
	fi

	gnome2_src_prepare
}

multilib_src_configure() {
	filter-flags -fno-exceptions #84263

	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(multilib_native_use_enable gtk-doc documentation) \
		$(use_enable static-libs static)
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_install_all() {
	einstalldocs

	# Note: html docs are installed into /usr/share/doc/libsigc++-2.0
	# We can't use /usr/share/doc/${PF} because of links from glibmm etc. docs
	use gtk-doc && dodoc -r examples
}
