# Distributed under the terms of the GNU General Public License v2

EAPI="8"

MY_PN="NetworkManager-sstp"
MY_P="${MY_PN}-${PV}"

inherit autotools

DESCRIPTION="Client for the proprietary Microsoft Secure Socket Tunneling Protocol(SSTP)"
HOMEPAGE="https://gitlab.gnome.org/GNOME/network-manager-sstp https://sourceforge.net/projects/sstp-client/"
SRC_URI="mirror://sourceforge/project/sstp-client/network-manager-sstp//${MY_P}.tar.bz2"

S="${WORKDIR}/${MY_P}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"

IUSE="gtk gtk4 +legacy"

# As of 1.3.0, if want GUI support, GTK 3 is always needed, even with GTK 4.
# atk/graphene/harfbuzz/cairo/gdk-pixbuf/pango are all standard "dragged in by gtk/glib"
# deps.
RDEPEND=">=dev-libs/glib-2.32:2
	net-misc/sstp-client
	>=net-misc/networkmanager-1.1.0:=
	net-dialup/ppp:=
	net-libs/gnutls:=
	gtk? (
		!legacy? ( >=net-libs/libnma-1.2.0 )
		>=app-crypt/libsecret-0.18
		>=x11-libs/gtk+-3.4:3

		gtk4? (
			dev-libs/atk
			media-libs/graphene
			media-libs/harfbuzz:=
			x11-libs/cairo
			x11-libs/gdk-pixbuf:2
			x11-libs/pango

			gui-libs/gtk:4
		)
	)"
DEPEND="${RDEPEND}"
BDEPEND="dev-util/gdbus-codegen
	dev-util/intltool
	virtual/pkgconfig
	sys-apps/file
	sys-devel/gettext"

PATCHES=(
	"${FILESDIR}"/${PN}-1.3.0-fix-configure.ac-bashisms.patch
)

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	local PPPD_VER="$(best_version net-dialup/ppp)"
	# Reduce it to ${PV}-${PR}
	PPPD_VER=${PPPD_VER#*/*-}
	# Main version without beta/pre/patch/revision
	PPPD_VER=${PPPD_VER%%[_-]*}

	econf \
		--disable-more-warnings \
		--with-dist-version=Gentoo \
		--with-pppd-plugin-dir="${EPREFIX}/usr/$(get_libdir)/pppd/${PPPD_VER}" \
		$(use_with gtk gnome) \
		$(use_with gtk4) \
		$(use_with legacy libnm-glib)
}

src_install() {
	default

	# From AppStream (the /usr/share/appdata location is deprecated):
	# 	https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html#spec-component-location
	# 	https://bugs.gentoo.org/709450
	mv "${ED}"/usr/share/{appdata,metainfo} || die

	find "${ED}" -type f -name "*.la" -delete || die
}
