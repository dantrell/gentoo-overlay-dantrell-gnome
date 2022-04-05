# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_8,3_9,3_10} )

inherit gnome.org meson python-r1 virtualx xdg

DESCRIPTION="Python bindings for GObject Introspection"
HOMEPAGE="https://pygobject.readthedocs.io/"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="*"

IUSE="+cairo examples test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="!test? ( test )"

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.56:2
	>=dev-libs/gobject-introspection-1.56:=
	dev-libs/libffi:=
	cairo? (
		>=dev-python/pycairo-1.16.0[${PYTHON_USEDEP}]
		x11-libs/cairo[glib] )
"
DEPEND="${RDEPEND}
	test? (
		dev-libs/atk[introspection]
		dev-python/pytest[${PYTHON_USEDEP}]
		x11-libs/gdk-pixbuf:2[introspection,jpeg]
		x11-libs/gtk+:3[introspection]
		x11-libs/pango[introspection]
	)
"
BDEPEND="
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.42.0-dynamicimporter-py310.patch
)

src_configure() {
	configuring() {
		meson_src_configure \
			$(meson_feature cairo pycairo) \
			$(meson_use test tests) \
			-Dpython="${EPYTHON}"
	}

	python_foreach_impl configuring
}

src_compile() {
	python_foreach_impl meson_src_compile
}

src_test() {
	local -x GIO_USE_VFS="local" # prevents odd issues with deleting ${T}/.gvfs
	local -x GIO_USE_VOLUME_MONITOR="unix" # prevent udisks-related failures in chroots, bug #449484

	testing() {
		local -x XDG_CACHE_HOME="${T}/${EPYTHON}"
		meson_src_test --timeout-multiplier 3 || die "test failed for ${EPYTHON}"
	}
	virtx python_foreach_impl testing
}

src_install() {
	installing() {
		meson_src_install
		python_optimize
	}
	python_foreach_impl installing
	use examples && dodoc -r examples
}
