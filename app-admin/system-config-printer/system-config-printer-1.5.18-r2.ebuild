# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
PYTHON_REQ_USE="xml(+)"

inherit distutils-r1 systemd udev xdg

DESCRIPTION="Graphical user interface for CUPS administration"
HOMEPAGE="https://github.com/OpenPrinting/system-config-printer"
SRC_URI="
	https://github.com/OpenPrinting/${PN}/releases/download/v${PV}/${P}.tar.xz
"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE="keyring policykit"

# Needs cups running, bug 284005
RESTRICT="test"

# Additional unhandled dependencies
# python samba client: smbc
# selinux: needed for troubleshooting
DEPEND="
	dev-libs/glib:2
	net-print/cups[dbus]
	virtual/libusb:1
	>=virtual/udev-172
	x11-libs/gtk+:3[introspection]
	x11-libs/libnotify[introspection]
	x11-libs/pango[introspection]
"
BDEPEND="
	app-text/docbook-xml-dtd:4.1.2
	>=app-text/xmlto-0.0.22
	dev-perl/XML-Parser
	dev-util/desktop-file-utils
	>=sys-devel/gettext-0.20
	virtual/pkgconfig
"
RDEPEND="
	${DEPEND}
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pycups[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/urllib3[${PYTHON_USEDEP}]
	')
	keyring? ( app-crypt/libsecret[introspection] )
	policykit? ( net-print/cups-pk-helper )
"

PATCHES=(
	# git master (1.5.19)
	"${FILESDIR}"/${PN}-1.5.18-fix-debugprint-exception.patch
)

src_configure() {
	local myeconfargs=(
		--with-xmlto
		--enable-nls
		--with-desktop-vendor=Gentoo
		--with-udev-rules
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	emake PYTHON=:
	distutils-r1_src_compile
}

src_install() {
	emake DESTDIR="${D}" PYTHON=: install
	python_fix_shebang "${ED}"
	distutils-r1_src_install
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
