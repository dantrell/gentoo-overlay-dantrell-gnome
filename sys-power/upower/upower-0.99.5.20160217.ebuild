# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools systemd

DESCRIPTION="An abstraction for enumerating power devices, listening to device events and querying history and statistics"
HOMEPAGE="https://upower.freedesktop.org/"
SRC_URI="https://${PN}.freedesktop.org/releases/${PN}-0.99.3.tar.xz"

LICENSE="GPL-2"
SLOT="0/3" # based on SONAME of libupower-glib.so
KEYWORDS="*"

IUSE="doc +deprecated integration-test +introspection ios kernel_FreeBSD kernel_linux selinux"

COMMON_DEPS="
	>=dev-libs/dbus-glib-0.100
	>=dev-libs/glib-2.34:2
	dev-util/gdbus-codegen
	sys-apps/dbus:=
	>=sys-auth/polkit-0.110
	deprecated? (
		sys-power/acpid
		sys-power/pm-utils
	)
	integration-test? ( dev-util/umockdev )
	introspection? ( dev-libs/gobject-introspection:= )
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
RDEPEND="
	${COMMON_DEPS}
	selinux? ( sec-policy/selinux-devicekit )
"
DEPEND="
	${COMMON_DEPS}
	doc? ( dev-util/gtk-doc )
	app-text/docbook-xsl-stylesheets
	dev-libs/gobject-introspection-common
	dev-libs/libxslt
	dev-util/intltool
	virtual/pkgconfig
"

QA_MULTILIB_PATHS="usr/lib/${PN}/.*"

S="${WORKDIR}/${PN}-0.99.3"

src_prepare() {
	# From Upstream:
	# 	https://cgit.freedesktop.org/upower/commit/?id=95e8a2a316872bf5e6b262ccc3a165cca8240d27
	# 	https://cgit.freedesktop.org/upower/commit/?id=fe37183fba649b999af3f66b9e0b0d70a054426c
	# 	https://cgit.freedesktop.org/upower/commit/?id=c9b2e177267b623850b3deedb1242de7d2e413ee
	# 	https://cgit.freedesktop.org/upower/commit/?id=77239cc4470fc515e1c8c6c21005fa08f3b1b04e
	# 	https://cgit.freedesktop.org/upower/commit/?id=305f62adf052aa972523d083ca44d3050f659ec9
	# 	https://cgit.freedesktop.org/upower/commit/?id=1e4f711df426a695c232b4164b1333349cb9512a
	# 	https://cgit.freedesktop.org/upower/commit/?id=ae9f8521c6f900255df1b6c7bc9f6adfd09abda5
	# 	https://cgit.freedesktop.org/upower/commit/?id=fc27cbd5cb098ccf6c70110fe1b894987328fc0d
	# 	https://cgit.freedesktop.org/upower/commit/?id=a037cffdeeed92fe7f6e68f04209b9cbe0422f8f
	# 	https://cgit.freedesktop.org/upower/commit/?id=da7517137e7a67ccfcf60093b2eab466aeaf71ad
	# 	https://cgit.freedesktop.org/upower/commit/?id=0825c162d3dc909966b10fecabbc2c1da364c1a6
	# 	https://cgit.freedesktop.org/upower/commit/?id=b6dfa473f81408771d1422242b07974b425a6fd2
	# 	https://cgit.freedesktop.org/upower/commit/?id=c015e6b21e3cb8f5bc944564850d9ffc35a6a6c7
	# 	https://cgit.freedesktop.org/upower/commit/?id=d5ec9d4f292726d1695f5154e546ac8536bf454d
	# 	https://cgit.freedesktop.org/upower/commit/?id=34caba296423c7737be7018279fd44161e8ac86f
	# 	https://cgit.freedesktop.org/upower/commit/?id=057f1bf338802c02425149d318d3b9317d8cd86b
	# 	https://cgit.freedesktop.org/upower/commit/?id=db4f9b43dfe6b4d2b5063ae352d8eba017652fce
	# 	https://cgit.freedesktop.org/upower/commit/?id=3e49e659d06749e04466f7a9501f27face8ef9ef
	# 	https://cgit.freedesktop.org/upower/commit/?id=f9b7e936ec2578e58d53542f60c60787e56395f0
	# 	https://cgit.freedesktop.org/upower/commit/?id=8f088fa5d78b2aa549d4546bd25441b8c6cd5feb
	# 	https://cgit.freedesktop.org/upower/commit/?id=b68131796a338e24427a04d73ee7efd1745f01ee
	eapply "${FILESDIR}"/${PN}-0.99.4-0001-trivial-post-release-version-bump.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0002-lib-fix-memory-leak-in-up-client-get-devices.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0003-linux-fix-possible-double-free.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0004-bsd-add-critical-action-support-for-bsd.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0005-rules-add-support-for-logitech-g700s-g700-gaming-mou.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0006-revert-linux-work-around-broken-battery-on-the-onda.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0007-fix-hid-rules-header-as-per-discussions.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0008-update-upower-hid-rules-supported-devices-list.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0009-up-tool-remove-unused-variables.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0017-integration-test-fix-typo-in-interface-name.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0025-support-g-autoptr-for-all-libupower-glib-object-type.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0026-build-fix-missing-includes.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0028-linux-fix-deprecation-warning-in-integration-test.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0029-daemon-print-the-filename-when-the-config-file-is-mi.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0030-daemon-fix-self-test-config-file-location-for-newer.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0031-rules-fix-distcheck-ing-not-being-able-to-install-ud.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0032-etc-change-the-default-low-battery-policy.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0034-daemon-lower-the-warning-levels-for-input-devices.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0035-released-upower-0.99.4.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0036-trivial-post-release-version-bump.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0037-update-readme.patch

	if use deprecated; then
		# From Funtoo:
		# 	https://bugs.funtoo.org/browse/FL-1329
		eapply "${FILESDIR}"/${PN}-0.99.2-restore-deprecated-code.patch

		# From Debian:
		#	https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718458
		#	https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718491
		eapply "${FILESDIR}"/${PN}-0.99.0-always-use-pm-utils-backend.patch

		if use integration-test; then
			# From Upstream:
			# 	https://cgit.freedesktop.org/upower/commit/?id=720680d6855061b136ecc9ff756fb0cc2bc3ae2c
			eapply "${FILESDIR}"/${PN}-0.99.2-fix-integration-test.patch
		fi
	fi

	eapply_user

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
		--disable-static \
		--disable-tests \
		--enable-man-pages \
		--libexecdir="${EPREFIX}"/usr/lib/${PN} \
		--localstatedir="${EPREFIX}"/var \
		--with-backend=${backend} \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
		--with-systemdutildir="$(systemd_get_utildir)" \
		$(use_enable deprecated) \
		$(use_enable doc gtk-doc) \
		$(use_enable doc gtk-doc-html) \
		$(use_enable introspection) \
		$(use_with ios idevice)
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
