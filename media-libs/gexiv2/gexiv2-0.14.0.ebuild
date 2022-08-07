# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_8,3_9,3_10,3_11} )

inherit meson python-r1 vala

DESCRIPTION="GObject-based wrapper around the Exiv2 library"
HOMEPAGE="https://wiki.gnome.org/Projects/gexiv2"
SRC_URI="mirror://gnome/sources/${PN}/$(ver_cut 1-2)/${P}.tar.xz"

LICENSE="LGPL-2.1+ GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="gtk-doc +introspection python test +vala"
REQUIRED_USE="
	python? ( introspection ${PYTHON_REQUIRED_USE} )
	test? ( python introspection )
	vala? ( introspection )
"

RESTRICT="!test? ( test )"

RDEPEND="
	>=media-gfx/exiv2-0.26:=
	>=dev-libs/glib-2.46.0:2
	introspection? ( dev-libs/gobject-introspection:= )
	python? (
		${PYTHON_DEPS}
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? (
		dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.3
	)
	test? ( media-gfx/exiv2[xmp] )
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.14.0-clean-up-python-support.patch
)

src_prepare() {
	default
	use vala && vala_setup
}

src_configure() {
	local emesonargs=(
		$(meson_use gtk-doc gtk_doc)
		$(meson_use introspection)
		$(meson_use vala vapi)
		-Dtools=true
		# Prevents installation of python modules (uses install_data from meson
		# which does not optimize the modules)
		-Dpython3=false
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	if use python ; then
		python_moduleinto gi/overrides/
		python_foreach_impl python_domodule GExiv2.py
		python_foreach_impl python_optimize
	fi
}
