# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit mono-env gnome2 vala flag-o-matic

DESCRIPTION="Utilities for creating and parsing messages using MIME"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gmime http://spruce.sourceforge.net/gmime/"

LICENSE="LGPL-2.1"
SLOT="2.6"
KEYWORDS="*"

IUSE="doc mono smime static-libs test vala"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.32.0:2
	sys-libs/zlib
	mono? (
		dev-lang/mono
		>=dev-dotnet/gtk-sharp-2.12.21:2 )
	smime? ( >=app-crypt/gpgme-1.1.6:= )
	vala? (
		$(vala_depend)
		>=dev-libs/gobject-introspection-1.30.0:= )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.8
	virtual/libiconv
	virtual/pkgconfig
	doc? ( app-text/docbook-sgml-utils )
	test? ( app-crypt/gnupg )
"
# gnupg is needed for tests if --enable-cryptography is enabled, which we do unconditionally

pkg_setup() {
	use mono && mono-env_pkg_setup
}

src_prepare() {
	gnome2_src_prepare
	use vala && vala_src_prepare
}

src_configure() {
	[[ ${CHOST} == *-solaris* ]] && append-libs iconv
	gnome2_src_configure \
		--enable-cryptography \
		--disable-strict-parser \
		$(use_enable mono) \
		$(use_enable smime) \
		$(use_enable static-libs static) \
		$(use_enable vala)
}

src_compile() {
	MONO_PATH="${S}" gnome2_src_compile
	if use doc; then
		emake -C docs/tutorial html
	fi
}

src_install() {
	GACUTIL_FLAGS="/root '${ED}/usr/$(get_libdir)' /gacdir '${EPREFIX}/usr/$(get_libdir)' /package ${PN}" \
		gnome2_src_install

	if use doc ; then
		docinto tutorial
		dodoc -r docs/tutorial/html/
	fi
}
