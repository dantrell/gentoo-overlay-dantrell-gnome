# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_6,3_7,3_8,3_9} )

inherit autotools python-r1 vala xdg-utils

DESCRIPTION="GObject-based wrapper around the Exiv2 library"
HOMEPAGE="https://wiki.gnome.org/Projects/gexiv2"
SRC_URI="mirror://gnome/sources/${PN}/$(ver_cut 1-2)/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="gtk-doc +introspection python test +vala"

REQUIRED_USE="
	python? ( introspection ${PYTHON_REQUIRED_USE} )
	test? ( python introspection )
	vala? ( introspection )
"

RESTRICT="!test? ( test )"

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.26.1:2
	>=media-gfx/exiv2-0.21:=
	introspection? ( dev-libs/gobject-introspection:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? ( dev-util/gtk-doc )
	test? (
		dev-python/pygobject:3
		media-gfx/exiv2[xmp]
	)
	vala? ( $(vala_depend) )
"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gexiv2/commit/abf4c28107327ce7fd18872ea045b259cda9436d
	eapply -R "${FILESDIR}"/${PN}-0.10.9-use-g-add-private.patch

	xdg_environment_reset
	tc-export CXX
	use vala && vala_src_prepare
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable introspection) \
		$(use_enable vala)
}

src_install() {
	emake DESTDIR="${D}" LIB="$(get_libdir)" install

	if use python ; then
		python_moduleinto gi/overrides/
		python_foreach_impl python_domodule GExiv2.py
	fi
}
