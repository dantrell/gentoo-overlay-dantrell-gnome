# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"
PYTHON_COMPAT=( python{3_8,3_9,3_10} )

inherit gnome.org gnome2-utils meson python-any-r1 vala xdg

DESCRIPTION="Libraries for cryptographic UIs and accessing PKCS#11 modules"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gcr"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0/1" # subslot = suffix of libgcr-base-3 and co
KEYWORDS="*"

IUSE="gtk gtk-doc +introspection test +vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/glib-2.44.0:2
	>=dev-libs/libgcrypt-1.2.2:0=
	>=app-crypt/p11-kit-0.19.0
	gtk? ( >=x11-libs/gtk+-3.22:3[introspection?] )
	>=sys-apps/dbus-1
	introspection? ( >=dev-libs/gobject-introspection-1.58:= )
"
RDEPEND="${DEPEND}"
PDEPEND="app-crypt/gnupg"
BDEPEND="
	${PYTHON_DEPS}
	gtk? ( dev-libs/libxml2:2 )
	dev-util/gdbus-codegen
	gtk-doc? (
		>=dev-util/gtk-doc-1.9
		app-text/docbook-xml-dtd:4.1.2
	)
	>=sys-devel/gettext-0.19.8
	test? ( app-crypt/gnupg )
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.38.0-optional-vapi.patch
	# From Gentoo:
	# 	https://bugs.gentoo.org/831428
	"${FILESDIR}"/${PN}-3.40.0-meson-0.61-build.patch
)

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	use vala && vala_src_prepare
	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use introspection)
		$(meson_use gtk)
		$(meson_use gtk-doc gtk_doc)
		-Dgpg_path="${EPREFIX}"/usr/bin/gpg
		$(meson_use vala vapi)
	)
	meson_src_configure
}

src_test() {
	dbus-run-session meson test -C "${BUILD_DIR}" || die 'tests failed'
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
