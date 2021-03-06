# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_6,3_7,3_8,3_9} )
VALA_USE_DEPEND="vapigen"

inherit gnome.org meson python-r1 vala

DESCRIPTION="Git library for GLib"
HOMEPAGE="https://wiki.gnome.org/Projects/Libgit2-glib"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk-doc python +ssh +vala"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

# libgit2-glib is now compatible with SOVERSION 26..28 of libgit2.
RDEPEND="
	>=dev-libs/gobject-introspection-0.10.1:=
	>=dev-libs/glib-2.42.0:2
	<dev-libs/libgit2-0.29:0=[ssh?]
	>=dev-libs/libgit2-0.26.0:0
	gtk-doc? ( >=dev-util/gtk-doc-am-1.11 )
	python? (
		${PYTHON_DEPS}
		dev-python/pygobject:3[${PYTHON_USEDEP}] )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	# Lower the minimum required GLib version
	sed -i meson.build \
		-e 's/2.44.0/2.42.0/' || die

	default
	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		-D gtk_doc=$(usex gtk-doc true false)
		-D introspection=true
		-D python=true
		-D ssh=$(usex ssh true false)
		-D vapi=$(usex vala true false)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	if use python ; then
		python_moduleinto gi.overrides
		python_foreach_impl python_domodule libgit2-glib/Ggit.py
	fi
}
