# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python{3_8,3_9,3_10,3_11} )

inherit gnome.org gnome2-utils meson python-any-r1 vala xdg

DESCRIPTION="Libraries for cryptographic UIs and accessing PKCS#11 modules"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gcr"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0/1" # subslot = suffix of libgcr-base-3 and co
KEYWORDS="*"

IUSE="gtk gtk-doc +introspection systemd test +vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/glib-2.44.0:2
	>=dev-libs/libgcrypt-1.2.2:0=
	>=app-crypt/p11-kit-0.19.0
	>=app-crypt/libsecret-0.20
	systemd? ( sys-apps/systemd:= )
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
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gcr/-/commit/96e76ee482dad2a0d71f9a5a5a6558d272d538ca
	"${FILESDIR}"/${PN}-9999-unbreak-build-without-systemd.patch
)

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	default
	use vala && vala_setup
	xdg_environment_reset
}

src_configure() {
	local emesonargs=(
		$(meson_use introspection)
		$(meson_use gtk)
		$(meson_use gtk-doc gtk_doc)
		-Dgpg_path="${EPREFIX}"/usr/bin/gpg
		-Dssh_agent=true
		$(meson_feature systemd)
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
