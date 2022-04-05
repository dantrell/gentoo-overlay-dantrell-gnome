# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2 multilib-minimal

DESCRIPTION="C++ bindings for the Cairo vector graphics library"
HOMEPAGE="https://cairographics.org/cairomm/"
SRC_URI="https://www.cairographics.org/releases/${P}.tar.gz"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="aqua doc +svg X"

RESTRICT="mirror"

RDEPEND="
	>=x11-libs/cairo-1.12.10[aqua=,svg=,X=,${MULTILIB_USEDEP}]
	dev-libs/libsigc++:2=[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-2.5.1:2[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? (
		app-doc/doxygen
		dev-libs/libxslt
		media-gfx/graphviz )
"

src_prepare() {
	# don't waste time building examples because they are marked as "noinst"
	sed -i 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' Makefile.in || die

	# don't waste time building tests
	# they require the boost Unit Testing framework, that's not in base boost
	sed -i 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' Makefile.in || die

	gnome2_src_prepare
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" gnome2_src_configure \
		--disable-tests \
		$(multilib_native_use_enable doc documentation)
}

multilib_src_install() {
	gnome2_src_install
}
