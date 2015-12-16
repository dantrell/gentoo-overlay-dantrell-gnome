# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit autotools eutils systemd

DESCRIPTION="D-Bus abstraction for enumerating power devices and querying history and statistics"
HOMEPAGE="http://upower.freedesktop.org/"
SRC_URI="http://${PN}.freedesktop.org/releases/${PN}-0.99.3.tar.xz"

LICENSE="GPL-2"
SLOT="0/3" # based on SONAME of libupower-glib.so
KEYWORDS="*"

IUSE="doc +deprecated integration-test +introspection ios kernel_FreeBSD kernel_linux"

RDEPEND="
	>=dev-libs/dbus-glib-0.100
	>=dev-libs/glib-2.40
	dev-util/gdbus-codegen
	sys-apps/dbus:=
	>=sys-auth/polkit-0.110
	deprecated? (
		sys-power/acpid
		sys-power/pm-utils
	)
	doc? ( dev-util/gtk-doc )
	integration-test? ( dev-util/umockdev )
	introspection? ( dev-libs/gobject-introspection )
	kernel_linux? (
		virtual/libusb:1
		virtual/libgudev:=
		virtual/udev
		ios? (
			>=app-pda/libimobiledevice-1:=
			>=app-pda/libplist-1:=
		)
	)
"
DEPEND="
	${RDEPEND}
	app-text/docbook-xsl-stylesheets
	dev-libs/gobject-introspection-common
	dev-libs/libxslt
	dev-util/intltool
	virtual/pkgconfig
"

QA_MULTILIB_PATHS="usr/lib/${PN}/.*"

DOCS="AUTHORS HACKING NEWS README"

S="${WORKDIR}/${PN}-0.99.3"

src_prepare() {
	# From Upstream:
	# 	http://cgit.freedesktop.org/upower/commit/?id=95e8a2a316872bf5e6b262ccc3a165cca8240d27
	# 	http://cgit.freedesktop.org/upower/commit/?id=fe37183fba649b999af3f66b9e0b0d70a054426c
	# 	http://cgit.freedesktop.org/upower/commit/?id=c9b2e177267b623850b3deedb1242de7d2e413ee
	# 	http://cgit.freedesktop.org/upower/commit/?id=77239cc4470fc515e1c8c6c21005fa08f3b1b04e
	# 	http://cgit.freedesktop.org/upower/commit/?id=305f62adf052aa972523d083ca44d3050f659ec9
	# 	http://cgit.freedesktop.org/upower/commit/?id=1e4f711df426a695c232b4164b1333349cb9512a
	# 	http://cgit.freedesktop.org/upower/commit/?id=ae9f8521c6f900255df1b6c7bc9f6adfd09abda5
	# 	http://cgit.freedesktop.org/upower/commit/?id=fc27cbd5cb098ccf6c70110fe1b894987328fc0d
	epatch "${FILESDIR}"/${PN}-0.99.4-0001-trivial-post-release-version-bump.patch
	epatch "${FILESDIR}"/${PN}-0.99.4-0002-lib-fix-memory-leak-in-up-client-get-devices.patch
	epatch "${FILESDIR}"/${PN}-0.99.4-0003-linux-fix-possible-double-free.patch
	epatch "${FILESDIR}"/${PN}-0.99.4-0004-bsd-add-critical-action-support-for-bsd.patch
	epatch "${FILESDIR}"/${PN}-0.99.4-0005-rules-add-support-for-logitech-g700s-g700-gaming-mou.patch
	epatch "${FILESDIR}"/${PN}-0.99.4-0006-revert-linux-work-around-broken-battery-on-the-onda.patch
	epatch "${FILESDIR}"/${PN}-0.99.4-0007-fix-hid-rules-header-as-per-discussions.patch
	epatch "${FILESDIR}"/${PN}-1.0.0-0008-update-upower-hid-rules-supported-devices-list.patch

	if use deprecated; then
		# From Funtoo:
		# 	https://bugs.funtoo.org/browse/FL-1329
		epatch "${FILESDIR}"/${PN}-0.99.2-restore-deprecated-code.patch

		# From Debian:
		#	https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718458
		#	https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718491
		epatch "${FILESDIR}"/${PN}-0.99.0-always-use-pm-utils-backend.patch

		if use integration-test; then
			# From Upstream:
			# 	http://cgit.freedesktop.org/upower/commit/?id=720680d6855061b136ecc9ff756fb0cc2bc3ae2c
			epatch "${FILESDIR}"/${PN}-0.99.2-fix-integration-test.patch
		fi
	fi

	eautoreconf
}

src_configure() {
	local backend

	if use kernel_linux; then
		backend=linux
	elif use kernel_FreeBSD; then
		backend=freebsd
	else
		backend=dummy
	fi

	econf \
		--libexecdir="${EPREFIX}"/usr/lib/${PN} \
		--localstatedir="${EPREFIX}"/var \
		--disable-static \
		--enable-man-pages \
		--disable-tests \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--with-backend=${backend} \
		$(use_enable deprecated) \
		$(use_enable doc gtk-doc) \
		$(use_enable doc gtk-doc-html) \
		$(use_enable introspection) \
		$(use_with ios idevice) \
		"$(systemd_with_utildir)" \
		"$(systemd_with_unitdir)"
}

src_install() {
	default

	if use doc; then
		# http://bugs.gentoo.org/487400
		insinto /usr/share/doc/${PF}/html/UPower
		doins doc/html/*
		dosym /usr/share/doc/${PF}/html/UPower /usr/share/gtk-doc/html/UPower
	fi

	if use integration-test; then
		newbin src/linux/integration-test upower-integration-test
	fi

	keepdir /var/lib/upower #383091
	prune_libtool_files
}
