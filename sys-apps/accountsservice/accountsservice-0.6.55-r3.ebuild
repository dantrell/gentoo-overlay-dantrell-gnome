# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit meson systemd

DESCRIPTION="D-Bus interfaces for querying and manipulating user account information"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/AccountsService/"
SRC_URI="https://www.freedesktop.org/software/${PN}/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="ck consolekit doc elogind gtk-doc +introspection selinux systemd"
REQUIRED_USE="?? ( ck consolekit elogind systemd )"

CDEPEND="
	>=dev-libs/glib-2.44:2
	sys-auth/polkit
	virtual/libcrypt:=
	ck? ( <sys-auth/consolekit-0.9 )
	consolekit? ( >=sys-auth/consolekit-0.9 )
	elogind? ( >=sys-auth/elogind-229.4 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.12:= )
	systemd? ( >=sys-apps/systemd-186:0= )
"
DEPEND="${CDEPEND}"
BDEPEND="
	dev-libs/libxslt
	dev-util/gdbus-codegen
	sys-devel/gettext
	virtual/pkgconfig
	doc? (
		app-text/docbook-xml-dtd:4.1.2
		app-text/xmlto )
	gtk-doc? (
		dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.3 )
"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-accountsd )
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.6.35-gentoo-system-users.patch
	"${FILESDIR}"/${PN}-0.6.55-meson-0.61-build.patch

	# From AccountsService:
	# 	https://cgit.freedesktop.org/accountsservice/commit/?id=435624d5c14ba8d2042b63d63aaf923803456768
	"${FILESDIR}"/${PN}-22.04.62-never-delete-the-root-filesystem-when-removing-users.patch
)

src_configure() {
	local emesonargs=(
		--localstatedir="${EPREFIX}/var"
		-Dsystemdsystemunitdir="$(systemd_get_systemunitdir)"
		-Dadmin_group="wheel"
		$(meson_use systemd)
		$(meson_use elogind)
		$(meson_use introspection)
		$(meson_use doc docbook)
		$(meson_use gtk-doc gtk_doc)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	# https://gitlab.freedesktop.org/accountsservice/accountsservice/-/issues/90
	if use doc; then
		mv "${ED}/usr/share/doc/${PN}" "${ED}/usr/share/doc/${PF}" || die
	fi

	# This directories are created at runtime when needed
	rm -r "${ED}"/var/lib || die
}
