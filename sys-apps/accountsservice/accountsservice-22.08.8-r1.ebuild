# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit meson python-any-r1 systemd

DESCRIPTION="D-Bus interfaces for querying and manipulating user account information"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/AccountsService/"
SRC_URI="https://www.freedesktop.org/software/${PN}/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="doc elogind gtk-doc +introspection selinux systemd test"
REQUIRED_USE="^^ ( elogind systemd )"

RESTRICT="!test? ( test )"

CDEPEND="
	>=dev-libs/glib-2.63.5:2
	sys-auth/polkit
	virtual/libcrypt:=
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
		app-text/xmlto
	)
	gtk-doc? (
		dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.3
	)
	test? (
		$(python_gen_any_dep '
			dev-python/python-dbusmock[${PYTHON_USEDEP}]
		')
	)
"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-accountsd )
"

PATCHES=(
	"${FILESDIR}"/${PN}-22.04.62-gentoo-system-users.patch
	"${FILESDIR}"/${PN}-22.08.8-configure-clang16.patch
)

python_check_deps() {
	if use test; then
		python_has_version "dev-python/python-dbusmock[${PYTHON_USEDEP}]"
	fi
}

src_prepare() {
	default

	# From AccountsService (remove unused codepath to lower GLib dependency):
	# 	https://cgit.freedesktop.org/accountsservice/commit/?id=b5903d5ae36f022117fe9b0c5308525c39cf5dc2
	# 	https://docs.gtk.org/glib/struct.StrvBuilder.html
	eapply -R "${FILESDIR}"/${PN}-22.04.62-daemon-dont-try-to-add-admin-users-to-non-existing-groups.patch
}

src_configure() {
	local emesonargs=(
		--localstatedir="${EPREFIX}/var"
		-Dsystemdsystemunitdir="$(systemd_get_systemunitdir)"
		-Dadmin_group="wheel"
		$(meson_use elogind)
		$(meson_use introspection)
		$(meson_use doc docbook)
		$(meson_use gtk-doc gtk_doc)
		-Dvapi=false
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
