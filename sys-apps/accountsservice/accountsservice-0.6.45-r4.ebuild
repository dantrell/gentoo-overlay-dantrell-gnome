# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_EAUTORECONF="yes"

inherit gnome2 systemd

DESCRIPTION="D-Bus interfaces for querying and manipulating user account information"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/AccountsService/"
SRC_URI="https://www.freedesktop.org/software/${PN}/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="ck consolekit doc elogind +introspection selinux systemd"
REQUIRED_USE="?? ( ck consolekit elogind systemd )"

CDEPEND="
	>=dev-libs/glib-2.37.3:2
	sys-auth/polkit
	virtual/libcrypt:=
	ck? ( <sys-auth/consolekit-0.9 )
	consolekit? ( >=sys-auth/consolekit-0.9 )
	elogind? ( sys-auth/elogind )
	introspection? ( >=dev-libs/gobject-introspection-0.9.12:= )
	systemd? ( >=sys-apps/systemd-186:0= )
"
DEPEND="${CDEPEND}
	dev-libs/libxslt
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.15
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
	doc? (
		app-text/docbook-xml-dtd:4.1.2
		app-text/xmlto
	)
"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-accountsd )
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.6.35-gentoo-system-users.patch
	"${FILESDIR}"/${PN}-0.6.45-support-elogind.patch
	"${FILESDIR}"/${PN}-0.6.46-daemon-dont-treat-explicitly-requested-users-as-cached.patch

	# From AccountsService:
	# 	https://cgit.freedesktop.org/accountsservice/commit/?id=435624d5c14ba8d2042b63d63aaf923803456768
	"${FILESDIR}"/${PN}-22.04.62-never-delete-the-root-filesystem-when-removing-users.patch
)

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--disable-more-warnings \
		--localstatedir="${EPREFIX}"/var \
		--enable-admin-group="wheel" \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
		$(use_enable doc docbook-docs) \
		$(use_enable elogind) \
		$(use_enable introspection) \
		$(use_enable systemd)
}
