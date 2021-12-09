# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit flag-o-matic gnome2 readme.gentoo-r1

DESCRIPTION="Archive manager for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/FileRoller"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE="nautilus"

# gdk-pixbuf used extensively in the source
# cairo used in eggtreemultidnd.c
# pango used in fr-window
RDEPEND="
	>=app-arch/libarchive-3:=
	>=dev-libs/glib-2.36:2
	>=dev-libs/json-glib-0.14
	>=x11-libs/gtk+-3.13.2:3
	>=x11-libs/libnotify-0.4.3:=
	sys-apps/file
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/pango
	nautilus? ( >=gnome-base/nautilus-3 )
"
DEPEND="${RDEPEND}
	dev-util/desktop-file-utils
	>=dev-util/intltool-0.40.0
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"
# eautoreconf needs:
#	gnome-base/gnome-common

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
${PN} is a frontend for several archiving utilities. If you want a
particular archive format support, see ${HOMEPAGE}
and install the relevant package. For example:
7-zip   - app-arch/p7zip
ace     - app-arch/unace
arj     - app-arch/arj
cpio    - app-arch/cpio
deb     - app-arch/dpkg
iso     - app-cdr/cdrtools
jar,zip - app-arch/zip and app-arch/unzip
lha     - app-arch/lha
lzop    - app-arch/lzop
rar     - app-arch/unrar or app-arch/unar
rpm     - app-arch/rpm
unstuff - app-arch/stuffit
zoo     - app-arch/zoo"

src_prepare() {
	# From GNOME (CVE-2020-11736):
	# 	https://gitlab.gnome.org/GNOME/file-roller/commit/45b2e76e25648961db621f898b4a9eb7c75ef4c0
	# 	https://gitlab.gnome.org/GNOME/file-roller/commit/8572946d3ebe25f392f110ee838ff5abc7a3e78e
	eapply "${FILESDIR}"/${PN}-3.32.5-libarchive-do-not-follow-external-links-when-extracting-files.patch
	eapply "${FILESDIR}"/${PN}-3.32.5-libarchive-overwrite-the-symbolic-link-as-well.patch

	# File providing Gentoo package names for various archivers
	cp -f "${FILESDIR}"/3.6.0-packages.match data/packages.match || die

	gnome2_src_prepare
}

src_configure() {
	# Work around -fno-common (GCC 10 default)
	append-flags -fcommon

	# --disable-debug because enabling it adds -O0 to CFLAGS
	gnome2_src_configure \
		--disable-run-in-place \
		--disable-static \
		--disable-debug \
		--enable-magic \
		--enable-libarchive \
		$(use_enable nautilus nautilus-actions) \
		--disable-packagekit
}

src_install() {
	gnome2_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	gnome2_pkg_postinst
	readme.gentoo_print_elog
}
