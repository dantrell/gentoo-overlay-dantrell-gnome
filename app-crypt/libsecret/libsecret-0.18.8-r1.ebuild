# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
VALA_USE_DEPEND=vapigen

inherit autotools gnome2 multilib-minimal python-any-r1 vala virtualx

DESCRIPTION="GObject library for accessing the freedesktop.org Secret Service API"
HOMEPAGE="https://wiki.gnome.org/Projects/Libsecret"

LICENSE="LGPL-2.1+ Apache-2.0" # Apache-2.0 license is used for tests only
SLOT="0"
KEYWORDS="*"

IUSE="+crypt +introspection test vala"
REQUIRED_USE="
	test? ( introspection )
	vala? ( introspection )
"

RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/glib-2.38:2[${MULTILIB_USEDEP}]
	crypt? ( >=dev-libs/libgcrypt-1.2.2:0=[${MULTILIB_USEDEP}] )
	introspection? ( >=dev-libs/gobject-introspection-1.29:= )
"
RDEPEND="${DEPEND}
	virtual/secret-service"
BDEPEND="
	dev-libs/libxslt
	dev-util/gdbus-codegen
	>=dev-build/gtk-doc-am-1.9
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	test? (
		$(python_gen_any_dep '
			dev-python/mock[${PYTHON_USEDEP}]
			dev-python/dbus-python[${PYTHON_USEDEP}]
			introspection? ( dev-python/pygobject:3[${PYTHON_USEDEP}] )')
		introspection? ( >=dev-libs/gjs-1.32 )
	)
	vala? ( $(vala_depend) )
"

python_check_deps() {
	if use introspection; then
		python_has_version "dev-python/pygobject:3[${PYTHON_USEDEP}]" || return
	fi
	python_has_version "dev-python/mock[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/dbus-python[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/libsecret/-/commit/80afd20c19389ffbae7a05f0e197dd1db50289ad
	eapply -R "${FILESDIR}"/${PN}-0.18.8-require-glib-2-44.patch

	eautoreconf
	use vala && vala_src_prepare
	gnome2_src_prepare

	# Drop unwanted CFLAGS modifications
	sed -e 's/CFLAGS="$CFLAGS -\(g\|O0\|O2\)"//' -i configure || die
}

multilib_src_configure() {
	local ECONF_SOURCE=${S}
	gnome2_src_configure \
		--enable-manpages \
		--disable-strict \
		--disable-coverage \
		--disable-static \
		$(use_enable crypt gcrypt) \
		$(multilib_native_use_enable introspection) \
		$(multilib_native_use_enable vala) \
		LIBGCRYPT_CONFIG="${EPREFIX}/usr/bin/${CHOST}-libgcrypt-config"

	if multilib_is_native_abi; then
		ln -s "${S}"/docs/reference/libsecret/html docs/reference/libsecret/html || die
	fi
}

multilib_src_test() {
	# tests fail without gobject-introspection, bug 655482
	multilib_is_native_abi && virtx emake check
}

multilib_src_install() {
	gnome2_src_install
}
