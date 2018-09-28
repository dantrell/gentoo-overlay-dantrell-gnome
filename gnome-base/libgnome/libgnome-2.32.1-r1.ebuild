# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"
GNOME_TARBALL_SUFFIX="bz2"

inherit gnome2 eutils

DESCRIPTION="Essential Gnome Libraries"
HOMEPAGE="https://library.gnome.org/devel/libgnome/stable/"
SRC_URI="${SRC_URI}
	branding? ( mirror://gentoo/gentoo-gdm-theme-r3.tar.bz2 )"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="branding"

RDEPEND="
	>=gnome-base/gconf-2
	>=dev-libs/glib-2.16:2
	>=gnome-base/gnome-vfs-2.5.3
	>=gnome-base/libbonobo-2.13
	>=dev-libs/popt-1.7
	media-libs/libcanberra
"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5
	dev-util/gtk-doc-am
	>=dev-util/intltool-0.40
	virtual/pkgconfig
"

PDEPEND="gnome-base/gvfs"

src_prepare() {
	# Make sure menus have icons. People don't like change
	epatch "${FILESDIR}"/${PN}-2.28.0-menus-have-icons.patch

	use branding && epatch "${FILESDIR}"/${PN}-2.26.0-branding.patch

	# Default to Adwaita theme over Clearlooks to proper gtk3 support
	sed -i -e 's/Clearlooks/Adwaita/' schemas/desktop_gnome_interface.schemas.in.in || die

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/libgnome/commit/33313713c4f5c1de500859ff128d6fd7e3af5722
	epatch "${FILESDIR}"/${PN}-2.32.2-gnome-config-h-fix-invalid-utf-8-in-header.patch

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--enable-canberra \
		--disable-esd
}

src_install() {
	gnome2_src_install

	if use branding; then
		# Add gentoo backgrounds
		dodir /usr/share/pixmaps/backgrounds/gnome/gentoo
		insinto /usr/share/pixmaps/backgrounds/gnome/gentoo
		doins "${WORKDIR}"/gentoo-emergence/gentoo-emergence.png
		doins "${WORKDIR}"/gentoo-cow/gentoo-cow-alpha.png
	fi
}
