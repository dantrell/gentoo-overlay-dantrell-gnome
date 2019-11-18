# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{2_7,3_5,3_6,3_7,3_8} )

inherit gnome2 python-r1 versionator

DESCRIPTION="Python client bindings for D-Bus AT-SPI"
HOMEPAGE="https://wiki.gnome.org/Accessibility"

# Note: only some of the tests are GPL-licensed, everything else is LGPL
LICENSE="LGPL-2 GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="" # test
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="${PYTHON_DEPS}
	>=dev-libs/atk-2.11.2
	dev-python/dbus-python[${PYTHON_USEDEP}]
	>=dev-python/pygobject-2.90.1:3[${PYTHON_USEDEP}]
"
RDEPEND="${COMMON_DEPEND}
	>=sys-apps/dbus-1
	>=app-accessibility/at-spi2-core-$(get_version_component_range 1-2)[introspection]
	!<gnome-extra/at-spi-1.32.0-r1
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

PATCHES=(
	# https://bugzilla.gnome.org/show_bug.cgi?id=689957
	"${FILESDIR}"/${PN}-2.6.0-examples-python3.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/pyatspi2/commit/63c8a0d6cce954bedae34a7f6ebc5807fbef0c14
	"${FILESDIR}"/${PN}-2.24.0-python-3-6-invalid-escape-sequence-deprecation-fix.patch
)

src_prepare() {
	gnome2_src_prepare
	python_copy_sources
}

src_configure() {
	python_foreach_impl run_in_build_dir gnome2_src_configure --disable-tests
}

src_compile() {
	python_foreach_impl run_in_build_dir gnome2_src_compile
}

src_install() {
	python_foreach_impl run_in_build_dir gnome2_src_install

	docinto examples
	dodoc examples/*.py
}
