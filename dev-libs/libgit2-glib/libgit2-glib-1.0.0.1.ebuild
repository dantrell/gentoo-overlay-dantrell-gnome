# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome.org meson python-r1 vala

DESCRIPTION="Git library for GLib"
HOMEPAGE="https://wiki.gnome.org/Projects/Libgit2-glib"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk-doc python +ssh +vala"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	>=dev-libs/gobject-introspection-0.10.1:=
	>=dev-libs/glib-2.42.0:2
	>=dev-libs/libgit2-0.26.0:0=[ssh?]
	python? (
		${PYTHON_DEPS}
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? (
		dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.1.2
	)
	vala? (
		$(vala_depend)
	)
"

src_prepare() {
	default

	# Lower the minimum required GLib version
	sed -e 's/2.44.0/2.42.0/' \
		-i meson.build || die

	use vala && vala_setup
}

src_configure() {
	local emesonargs=(
		$(meson_use gtk-doc gtk_doc)
		-Dintrospection=true
		-Dpython=false # we install python scripts manually
		$(meson_use ssh)
		$(meson_use vala vapi)
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
