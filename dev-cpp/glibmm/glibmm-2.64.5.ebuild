# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome.org meson-multilib python-any-r1

DESCRIPTION="C++ interface for glib2"
HOMEPAGE="https://www.gtkmm.org https://gitlab.gnome.org/GNOME/glibmm"

LICENSE="LGPL-2.1+"
SLOT="2"
KEYWORDS="*"

IUSE="debug gtk-doc test"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/libsigc++:2=[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-2.9.1:2[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.61.2:2[${MULTILIB_USEDEP}]
	>=dev-cpp/mm-common-1.0.0
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
	gtk-doc? (
		app-text/doxygen[dot]
		dev-lang/perl
		dev-perl/XML-Parser
		dev-libs/libxslt
		media-gfx/graphviz
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
		-Dmaintainer-mode=true
		-Dwarnings=min
		-Dbuild-deprecated-api=true
		$(meson_native_use_bool gtk-doc build-documentation)
		$(meson_use debug debug-refcounting)
		-Dbuild-examples=false
	)
	meson_src_configure
}
