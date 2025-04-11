# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome.org gnome2-utils meson python-any-r1 vala xdg

DESCRIPTION="Location and timezone database and weather-lookup library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibGWeather"

LICENSE="GPL-2+"
SLOT="4/4-0" # subslot = 4-(libgweather-4 soname suffix)
KEYWORDS=""

IUSE="gtk-doc +introspection test +vala"
REQUIRED_USE="
	vala? ( introspection )
	gtk-doc? ( introspection )
"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.68.0:2
	>=net-libs/libsoup-2.99.2:3.0
	sci-geosciences/geocode-glib:2
	>=dev-libs/libxml2-2.6.0:2
	dev-libs/json-glib
	introspection? ( >=dev-libs/gobject-introspection-1.54:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? ( >=dev-util/gi-docgen-2021.6 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	${PYTHON_DEPS}
	$(python_gen_any_dep 'dev-python/pygobject[${PYTHON_USEDEP}]')
	vala? ( $(vala_depend) )
"

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
	# The metar test requires network access
	if has network-sandbox ${FEATURES}; then
		sed -i -e '/metar/d' libgweather/tests/meson.build || die
	fi
}

src_configure() {
	local emesonargs=(
		$(meson_use vala enable_vala)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use introspection)
		$(meson_use test tests)
		-Dsoup2=false
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	if use gtk-doc; then
		mkdir -p "${ED}"/usr/share/gtk-doc/ || die
		mv "${ED}"/usr/share/doc/libgweather-4.0 "${ED}"/usr/share/gtk-doc/ || die
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
