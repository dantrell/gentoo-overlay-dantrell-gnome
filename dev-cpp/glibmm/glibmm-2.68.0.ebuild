# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson multilib-minimal

DESCRIPTION="C++ interface for glib2"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="2.68"
KEYWORDS=""

IUSE="doc debug test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.63.0:2[${MULTILIB_USEDEP}]
	dev-libs/libsigc++:3[doc?,${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? (
		app-doc/doxygen[dot]
		dev-lang/perl
		dev-libs/libxslt
	)
"

src_prepare() {
	default

	# giomm_tls_client requires FEATURES=-network-sandbox and glib-networking rdep
	sed -i -e '/giomm_tls_client/d' tests/meson.build || die

	if ! use test; then
		sed -i -e "/^subdir('tests')/d" meson.build || die
	fi
}

multilib_src_configure() {
	local emesonargs=(
		-Dwarnings=min
		-Dbuild-deprecated-api=true
		-Dbuild-documentation=$(usex doc true false)
		-Ddebug-refcounting=$(usex debug true false)
		-Dbuild-examples=false
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_test() {
	meson_src_test
}

multilib_src_install() {
	meson_src_install
}
