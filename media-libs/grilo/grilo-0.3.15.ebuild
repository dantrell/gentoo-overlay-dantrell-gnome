# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
VALA_MIN_API_VERSION="0.28"

inherit gnome.org meson python-any-r1 vala xdg

DESCRIPTION="A framework for easy media discovery and browsing"
HOMEPAGE="https://wiki.gnome.org/Projects/Grilo"

LICENSE="LGPL-2.1+"
SLOT="0.3/0" # subslot is libgrilo-0.3 soname suffix
KEYWORDS="*"

IUSE="gtk gtk-doc +introspection +network +playlist test vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

# oauth could be optional if meson is patched - used for flickr oauth in grilo-test-ui tool
RDEPEND="
	>=dev-libs/glib-2.66:2
	dev-libs/libxml2:2
	network? ( >=net-libs/libsoup-2.41.3:2.4[introspection?] )
	playlist? ( >=dev-libs/totem-pl-parser-3.4.1:= )
	introspection? ( >=dev-libs/gobject-introspection-1.0:= )

	gtk? (
		net-libs/liboauth
		>=x11-libs/gtk+-3.14:3
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	gtk-doc? (
		>=dev-util/gtk-doc-1.10
		app-text/docbook-xml-dtd:4.3
	)
	${PYTHON_DEPS}
	test? ( sys-apps/dbus )
	vala? ( $(vala_depend) )
"

src_prepare() {
	sed -i -e "s:'GETTEXT_PACKAGE', meson.project_name():'GETTEXT_PACKAGE', 'grilo-${SLOT%/*}':" meson.build || die
	sed -i -e "s:meson.project_name():'grilo-${SLOT%/*}':" po/meson.build || die
	sed -i -e "s:'grilo':'grilo-${SLOT%/*}':" doc/grilo/meson.build || die

	# Drop explicit unversioned vapigen check
	sed -i -e "/find_program.*vapigen/d" meson.build || die

	# Don't build examples; they get embedded in gtk-doc, thus we don't install the sources with USE=examples either
	sed -i -e "/subdir('examples')/d" meson.build || die

	default
	xdg_environment_reset
	use vala && vala_setup
}

src_configure() {
	local emesonargs=(
		$(meson_use network enable-grl-net)
		$(meson_use playlist enable-grl-pls)
		$(meson_use gtk-doc enable-gtk-doc)
		$(meson_use introspection enable-introspection)
		$(meson_use gtk enable-test-ui)
		$(meson_use vala enable-vala)
		-Dsoup3=false
	)
	meson_src_configure
}

src_test() {
	dbus-run-session meson test -C "${BUILD_DIR}" || die
}
