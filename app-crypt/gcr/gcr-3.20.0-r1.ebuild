# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"
PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit gnome2 multilib-minimal python-any-r1 vala virtualx

DESCRIPTION="Libraries for cryptographic UIs and accessing PKCS#11 modules"
HOMEPAGE="https://git.gnome.org/browse/gcr"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0/1" # subslot = suffix of libgcr-3
KEYWORDS=""

IUSE="debug gtk +introspection vala"
REQUIRED_USE="vala? ( introspection )"

COMMON_DEPEND="
	>=app-crypt/p11-kit-0.19[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.38:2[${MULTILIB_USEDEP}]
	>=dev-libs/libgcrypt-1.2.2:0=[${MULTILIB_USEDEP}]
	>=dev-libs/libtasn1-1:=[${MULTILIB_USEDEP}]
	>=sys-apps/dbus-1
	gtk? ( >=x11-libs/gtk+-3.12:3[X,introspection?] )
	introspection? ( >=dev-libs/gobject-introspection-1.34:= )
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-base/gnome-keyring-3.3
"
# gcr was part of gnome-keyring until 3.3
DEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	dev-libs/gobject-introspection-common
	dev-libs/libxslt
	dev-libs/vala-common
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig[${MULTILIB_USEDEP}]
	vala? ( $(vala_depend) )
"
# eautoreconf needs:
#	dev-libs/gobject-introspection-common
#	dev-libs/vala-common

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	# Disable stupid flag changes
	sed -e 's/CFLAGS="$CFLAGS -g"//' \
		-e 's/CFLAGS="$CFLAGS -O0"//' \
		-i configure.ac configure || die

	use vala && vala_src_prepare
	gnome2_src_prepare
}

multilib_src_configure() {
	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		$(multilib_native_use_with gtk) \
		$(multilib_native_use_enable introspection) \
		$(use_enable vala) \
		$(usex debug --enable-debug=yes --enable-debug=default) \
		--disable-update-icon-cache \
		--disable-update-mime
}

multilib_src_test() {
	virtx emake check
}

multilib_src_install() {
	gnome2_src_install
}

pkg_postinst() {
	gnome2_pkg_postinst

	multilib_pkg_postinst() {
		gnome2_giomodule_cache_update \
			|| die "Update GIO modules cache failed (for ${ABI})"
	}
	multilib_foreach_abi multilib_pkg_postinst
}
