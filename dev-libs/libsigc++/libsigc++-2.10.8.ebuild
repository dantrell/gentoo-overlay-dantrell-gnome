# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit flag-o-matic gnome.org meson-multilib

DESCRIPTION="Typesafe callback system for standard C++"
HOMEPAGE="https://libsigcplusplus.github.io/libsigcplusplus/
	https://github.com/libsigcplusplus/libsigcplusplus"

LICENSE="LGPL-2.1+"
SLOT="2/10"
KEYWORDS="*"

IUSE="gtk-doc test"

RESTRICT="!test? ( test )"

DEPEND="test? ( dev-libs/boost:=[${MULTILIB_USEDEP}] )"
BDEPEND="sys-devel/m4
	gtk-doc? ( app-doc/doxygen[dot] )"

multilib_src_configure() {
	filter-flags -fno-exceptions #84263

	local -a emesonargs=(
		$(meson_use test benchmark)
		$(meson_native_use_bool gtk-doc build-documentation)
		-Dbuild-examples=false
	)
	meson_src_configure
}

multilib_src_install_all() {
	# Note: html docs are installed into /usr/share/doc/libsigc++-2.0
	# We can't use /usr/share/doc/${PF} because of links from glibmm etc. docs
	:;
}
