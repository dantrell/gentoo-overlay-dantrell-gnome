# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_8,3_9,3_10} )
VALA_USE_DEPEND=vapigen

inherit gnome2 meson-multilib python-any-r1 vala virtualx

DESCRIPTION="GObject library for accessing the freedesktop.org Secret Service API"
HOMEPAGE="https://wiki.gnome.org/Projects/Libsecret"

LICENSE="LGPL-2.1+ Apache-2.0" # Apache-2.0 license is used for tests only
SLOT="0"
KEYWORDS="~*"

IUSE="+crypt gtk-doc +introspection test +vala"
REQUIRED_USE="
	vala? ( introspection )
	gtk-doc? ( crypt )
"

RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/glib-2.44:2[${MULTILIB_USEDEP}]
	crypt? ( >=dev-libs/libgcrypt-1.2.2:0=[${MULTILIB_USEDEP}] )
	introspection? ( >=dev-libs/gobject-introspection-1.29:= )
"
RDEPEND="${DEPEND}
	virtual/secret-service"
BDEPEND="
	app-text/docbook-xml-dtd:4.2
	dev-libs/libxslt
	dev-util/gdbus-codegen
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	gtk-doc? (
		app-text/docbook-xml-dtd:4.1.2
		dev-util/gtk-doc
	)
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
		has_version -b "dev-python/pygobject:3[${PYTHON_USEDEP}]" || return
	fi
	has_version -b "dev-python/mock[${PYTHON_USEDEP}]" &&
	has_version -b "dev-python/dbus-python[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	use vala && vala_src_prepare
	default

	# Remove @filename@ from the header template that would otherwise cause
	# differences dependent on the ABI
	sed -e '/enumerations from "@filename@"/d' \
		-i libsecret/secret-enum-types.h.template || die
}

multilib_src_configure() {
	local emesonargs=(
		$(meson_use crypt gcrypt)

		# Don't build docs multiple times
		$(meson_native_true manpage)
		$(meson_native_use_bool gtk-doc gtk_doc)

		$(meson_native_use_bool introspection)
		$(meson_native_use_bool vala vapi)
	)
	meson_src_configure
}

multilib_src_test() {
	virtx meson_src_test
}
