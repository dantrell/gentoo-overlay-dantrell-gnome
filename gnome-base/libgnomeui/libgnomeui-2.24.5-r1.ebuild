# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME2_LA_PUNT="yes"
GNOME_TARBALL_SUFFIX="bz2"

inherit gnome2

DESCRIPTION="User Interface routines for Gnome"
HOMEPAGE="https://library.gnome.org/devel/libgnomeui/stable/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="debug test"

RESTRICT="!test? ( test )"

# gtk+-2.14 dep instead of 2.12 ensures system doesn't loose VFS capabilities in GtkFilechooser
RDEPEND="
	dev-libs/atk
	>=dev-libs/glib-2.16:2
	>=dev-libs/libxml2-2.4.20:2
	>=dev-libs/popt-1.5
	>=gnome-base/gconf-2:2
	>=gnome-base/gnome-keyring-0.4
	>=gnome-base/gnome-vfs-2.7.3:2
	>=gnome-base/libgnome-2.13.7
	>=gnome-base/libgnomecanvas-2
	gnome-base/libgnome-keyring
	>=gnome-base/libbonoboui-2.13.1
	>=gnome-base/libglade-2:2.0
	media-libs/libart_lgpl
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-2.14:2
	>=x11-libs/pango-1.1.2
	x11-libs/libICE
	x11-libs/libSM
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/gtk-doc-am
	sys-devel/gettext
	virtual/pkgconfig
	>=dev-util/intltool-0.40
"
PDEPEND="x11-themes/adwaita-icon-theme"

src_prepare() {
	if ! use test; then
		sed 's/ test-gnome//' -i Makefile.am Makefile.in || die "sed failed"
	fi

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/libgnomeui/commit/30334c28794ef85d8973f4ed0779b5ceed6594f2
	eapply "${FILESDIR}"/${PN}-2.24.5-gnome-scores-h-convert-to-utf-8.patch

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(usex debug --enable-debug=yes ' ')
}
