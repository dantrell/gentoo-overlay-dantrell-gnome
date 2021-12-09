# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala

DESCRIPTION="Automatic archives creating and extracting library"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-autoar"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk +introspection vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=app-arch/libarchive-3.2.0
	>=dev-libs/glib-2.35.6:2
	gtk? ( >=x11-libs/gtk+-3.2:3[introspection?] )
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/gtk-doc-am-1.14
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

PATCHES=(
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gnome-autoar/commit/88e21e8aa2841216fa1d7fba617a8692912af51e
	# 	https://gitlab.gnome.org/GNOME/gnome-autoar/commit/c4b0b9c9b6522058dc43ee817b0e0bbd1f030617
	# 	https://gitlab.gnome.org/GNOME/gnome-autoar/commit/8109c368c6cfdb593faaf698c2bf5da32bb1ace4
	"${FILESDIR}"/${PN}-0.3.1-extractor-detect-conflict-also-for-directories.patch
	"${FILESDIR}"/${PN}-0.3.1-extractor-do-not-follow-symlinks-when-detecting-conflicts.patch
	"${FILESDIR}"/${PN}-0.3.1-extractor-do-not-allow-symlink-in-parents.patch
)

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		$(use_enable introspection) \
		$(use_enable vala) \
		$(use_enable gtk)
}
