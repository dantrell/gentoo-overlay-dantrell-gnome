# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{2_7,3_5,3_6,3_7,3_8} )

inherit meson python-r1 vala

DESCRIPTION="GObject-based wrapper around the Exiv2 library"
HOMEPAGE="https://wiki.gnome.org/Projects/gexiv2"
SRC_URI="mirror://gnome/sources/${PN}/$(ver_cut 1-2)/${P}.tar.xz"

LICENSE="LGPL-2.1+ GPL-2"
SLOT="0"
KEYWORDS="~*"

IUSE="gtk-doc +introspection python test +vala"

REQUIRED_USE="
	python? ( introspection ${PYTHON_REQUIRED_USE} )
	test? ( python introspection )
	vala? ( introspection )
"

RESTRICT="!test? ( test )"

BDEPEND="
	virtual/pkgconfig
	gtk-doc? ( dev-util/gtk-doc )
	test? (
		dev-python/pygobject:3
		media-gfx/exiv2[xmp]
	)
	vala? ( $(vala_depend) )
"
RDEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.46.0:2
	>=media-gfx/exiv2-0.21:=
	introspection? ( dev-libs/gobject-introspection:= )
"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use introspection)
		$(meson_use vala vapi)
		$(meson_use gtk-doc gtk_doc)
		-Dtools=true
		# Prevents installation of python modules (uses install_data from meson
		# which does not optimize the modules)
		-Dpython2_girdir=no
		-Dpython3_girdir=no
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	if use python ; then
		python_moduleinto gi/overrides/
		python_foreach_impl python_domodule GExiv2.py
	fi
}
