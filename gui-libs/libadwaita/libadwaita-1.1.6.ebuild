# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
VALA_MIN_API_VERSION="0.52"

inherit gnome.org meson python-any-r1 vala virtualx

DESCRIPTION="Building blocks for modern adaptive GNOME applications"
HOMEPAGE="https://gnome.pages.gitlab.gnome.org/libadwaita/ https://gitlab.gnome.org/GNOME/libadwaita"

LICENSE="LGPL-2.1+"
SLOT="1"
KEYWORDS="*"

IUSE="+introspection test +vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=dev-libs/glib-2.66:2
	>=gui-libs/gtk-4.5.0:4[introspection?]
	dev-libs/fribidi
	introspection? ( >=dev-libs/gobject-introspection-1.54:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	vala? ( $(vala_depend) )
	>=dev-build/meson-0.59.0
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.1.4-fix-aliasing.patch
)

src_prepare() {
	default
	use vala && vala_setup
}

src_configure() {
	local emesonargs=(
		# Never use gi-docgen subproject
		--wrap-mode nofallback

		-Dprofiling=false
		$(meson_feature introspection)
		$(meson_use vala vapi)
		-Dgtk_doc=false # we ship pregenerated docs
		$(meson_use test tests)
		-Dexamples=false
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test --timeout-multiplier 2
}

src_install() {
	meson_src_install

	insinto /usr/share/gtk-doc/html
	# This will install libadwaita API docs unconditionally, but this is intentional
	doins -r "${S}"/doc/libadwaita-1
}
