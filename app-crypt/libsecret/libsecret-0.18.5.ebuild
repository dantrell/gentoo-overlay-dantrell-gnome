# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="yes"
PYTHON_COMPAT=( python{3_3,3_4,3_5} )
VALA_USE_DEPEND=vapigen

inherit gnome2 python-any-r1 vala virtualx

DESCRIPTION="GObject library for accessing the freedesktop.org Secret Service API"
HOMEPAGE="https://wiki.gnome.org/Projects/Libsecret"

LICENSE="LGPL-2.1+ Apache-2.0" # Apache-2.0 license is used for tests only
SLOT="0"
KEYWORDS="*"

IUSE="+crypt +introspection test vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="mirror"

RDEPEND="
	>=dev-libs/glib-2.38:2
	crypt? ( >=dev-libs/libgcrypt-1.2.2:0= )
	introspection? ( >=dev-libs/gobject-introspection-1.29:= )
"
PDEPEND=">=gnome-base/gnome-keyring-3
"
# PDEPEND to avoid circular dep (bug #547456)
# Add ksecrets to PDEPEND when it's added to portage
DEPEND="${RDEPEND}
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.35.0
	sys-devel/gettext
	virtual/pkgconfig
	test? (
		dev-python/mock
		introspection? (
			${PYTHON_DEPS}
			>=dev-libs/gjs-1.32
			dev-python/pygobject:3 )
	)
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--enable-manpages \
		--disable-strict \
		--disable-coverage \
		--disable-static \
		$(use_enable crypt gcrypt) \
		$(use_enable introspection) \
		$(use_enable vala)
}

src_compile() {
	gnome2_src_compile -j1
}

src_test() {
	Xemake check
}
