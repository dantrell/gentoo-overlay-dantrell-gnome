# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_4,3_5,3_6,3_7} )
VALA_MIN_API_VERSION="0.32" # Needed when gtk+-3.20 is found

inherit gnome2 meson python-r1 vala

DESCRIPTION="git repository viewer for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Gitg"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="doc glade +python"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

# test if unbundling of libgd is possible
# Currently it seems not to be (unstable API/ABI)
RDEPEND="
	app-crypt/libsecret[vala]
	dev-libs/libgee:0.8[introspection]
	>=app-text/gtkspell-3.0.3:3[vala]
	>=dev-libs/glib-2.38:2[dbus]
	>=dev-libs/gobject-introspection-0.10.1:=
	dev-libs/libgit2:=[threads]

	>=dev-libs/libgit2-glib-0.26.4[ssh]
	<dev-libs/libgit2-glib-0.27.0

	>=dev-libs/libpeas-1.5.0[gtk]
	>=dev-libs/libxml2-2.9.0:2
	net-libs/libsoup:2.4
	>=gnome-base/gsettings-desktop-schemas-0.1.1
	>=x11-libs/gtk+-3.20.0:3
	>=x11-libs/gtksourceview-3.10:3.0
	x11-themes/adwaita-icon-theme
	glade? ( >=dev-util/glade-3.2:3.10 )
	python? (
		${PYTHON_DEPS}
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}
	$(vala_depend)
	>=dev-libs/libgit2-glib-0.24.4[vala]
	>=dev-util/intltool-0.40
	gnome-base/gnome-common
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

pkg_setup() {
	use python && [[ ${MERGE_TYPE} != binary ]] && python_setup
}

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D glade_catalog=$(usex glade true false)
		-D python=$(usex python true false)
		-D docs=$(usex doc true false)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	if use python ; then
		python_moduleinto gi.overrides
		python_foreach_impl python_domodule libgitg-ext/GitgExt.py
	fi
}
