# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic gnome2 multilib-minimal

DESCRIPTION="Generic Cascading Style Sheet (CSS) parsing and manipulation toolkit"
HOMEPAGE="https://gitlab.gnome.org/Archive/libcroco"

LICENSE="LGPL-2"
SLOT="0.6"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=dev-libs/libxml2-2.9.1-r4[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/gtk-doc-am
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.6.13-CVE-2020-12825.patch
	"${FILESDIR}"/${PN}-0.6.13-gcc-13.patch
)

src_prepare() {
	if ! use test; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS .*\=.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed failed"
	fi

	gnome2_src_prepare
}

multilib_src_configure() {
	# From GNOME:
	# 	https://gitlab.gnome.org/Archive/libcroco/-/issues/6
	# 	https://bugs.gentoo.org/855704
	append-cflags -Wno-error=strict-aliasing

	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		--disable-static \
		$([[ ${CHOST} == *-darwin* ]] && echo --disable-Bsymbolic)

	if multilib_is_native_abi; then
		ln -s "${S}"/docs/reference/html docs/reference/html || die
	fi
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_install_all() {
	einstalldocs
}
