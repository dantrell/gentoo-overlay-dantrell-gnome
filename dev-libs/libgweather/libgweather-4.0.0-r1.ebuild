# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome.org gnome2-utils meson python-any-r1 vala xdg

DESCRIPTION="Location and timezone database and weather-lookup library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibGWeather"

LICENSE="GPL-2+"
SLOT="4/4-0" # subslot = 4-(libgweather-4 soname suffix)
KEYWORDS="*"

IUSE="gtk-doc +introspection test +vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.68.0:2
	>=net-libs/libsoup-2.44:2.4
	>=dev-libs/libxml2-2.6.0:2
	sci-geosciences/geocode-glib:0

	introspection? ( >=dev-libs/gobject-introspection-1.54:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? (
		>=dev-util/gi-docgen-2021.6
		app-text/docbook-xml-dtd:4.3
	)
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	${PYTHON_DEPS}
	$(python_gen_any_dep 'dev-python/pygobject[${PYTHON_USEDEP}]')
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-4.0.0-autoskip-network-test.patch
	"${FILESDIR}"/${PN}-4.0.0-vapigen.patch
)

python_check_deps() {
	python_has_version "dev-python/pygobject[${PYTHON_USEDEP}]"
}

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	default
	gnome2_environment_reset
	use vala && vala_setup
}

src_configure() {
	local emesonargs=(
		$(meson_use vala enable_vala)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use introspection)
		$(meson_use test tests)
		-Dsoup2=true
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
