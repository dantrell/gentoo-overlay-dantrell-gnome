# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org flag-o-matic meson-multilib

DESCRIPTION="Typesafe callback system for standard C++"
HOMEPAGE="https://libsigcplusplus.github.io/libsigcplusplus/
	https://github.com/libsigcplusplus/libsigcplusplus"

LICENSE="LGPL-2.1+"
SLOT="3/2"
KEYWORDS="*"

IUSE="examples gtk-doc test"

RESTRICT="!test? ( test )"

BDEPEND="
	gtk-doc? (
		app-text/doxygen[dot]
		dev-lang/perl
		dev-libs/libxslt
	)
"

src_prepare() {
	default

	if ! use test; then
		sed -i -e "/^subdir('tests')/d" meson.build || die
	fi
}

multilib_src_configure() {
	filter-flags -fno-exceptions #84263

	local emesonargs=(
		-Dbuild-examples=false
		$(meson_native_use_bool gtk-doc build-documentation)
	)
	meson_src_configure
}

multilib_src_install_all() {
	# Note: html docs are installed into /usr/share/doc/libsigc++-3.0
	# We can't use /usr/share/doc/${PF} because of links from glibmm etc. docs
	use examples && dodoc -r examples
}
