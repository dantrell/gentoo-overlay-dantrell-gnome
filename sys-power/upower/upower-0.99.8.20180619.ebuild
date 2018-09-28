# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools ltprune systemd xdg-utils

DESCRIPTION="Abstraction for enumerating power devices, listening to device events and querying history and statistics"
HOMEPAGE="https://upower.freedesktop.org/"
SRC_URI="https://${PN}.freedesktop.org/releases/${PN}-0.99.3.tar.xz"

LICENSE="GPL-2"
SLOT="0/3" # based on SONAME of libupower-glib.so
KEYWORDS="~*"

IUSE="ck doc integration-test +introspection ios kernel_FreeBSD kernel_linux selinux"

COMMON_DEPS="
	>=dev-libs/dbus-glib-0.100
	>=dev-libs/glib-2.34:2
	dev-util/gdbus-codegen
	sys-apps/dbus:=
	>=sys-auth/polkit-0.110
	ck? (
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
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

QA_MULTILIB_PATHS="usr/lib/${PN}/.*"

S="${WORKDIR}/${PN}-0.99.3"

src_prepare() {
	# From UPower:
	# 	https://cgit.freedesktop.org/upower/log/
	eapply "${FILESDIR}"/${PN}-0.99.4-0001-trivial-post-release-version-bump.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0002-lib-fix-memory-leak-in-up-client-get-devices.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0003-linux-fix-possible-double-free.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0004-bsd-add-critical-action-support-for-bsd.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0005-rules-add-support-for-logitech-g700s-g700-gaming-mou.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0006-revert-linux-work-around-broken-battery-on-the-onda.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0007-fix-hid-rules-header-as-per-discussions.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0008-update-upower-hid-rules-supported-devices-list.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0009-up-tool-remove-unused-variables.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.4-0010-up-backend-remove-unused-private-member.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0011-daemon-port-upkbdbacklight-to-gdbus.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0012-daemon-port-upwakeups-to-gdbus.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0013-daemon-port-updaemon-to-gdbus.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0014-daemon-port-updevice-to-gdbus.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0015-daemon-port-main-to-gdbus.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0016-build-remove-dependency-on-dbus-glib-and-libdbus.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.4-0017-integration-test-fix-typo-in-interface-name.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.4-0018-share-generated-code-between-daemon-and-library.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0019-daemon-make-updevice-a-subclass-of-upexporteddevices.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0020-daemon-make-updaemon-a-subclass-of-upexporteddaemon.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0021-daemon-make-upkbdbacklight-a-subclass-of-upexportedk.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0022-daemon-make-upwakeups-a-subclass-of-upexportedwakeup.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0023-daemon-remove-custom-marshal-setup.patch
		eapply "${FILESDIR}"/${PN}-0.99.4-0024-fix-build-regression.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.4-0025-support-g-autoptr-for-all-libupower-glib-object-type.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0026-build-fix-missing-includes.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.4-0027-build-always-ship-upower-service-in.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.4-0028-linux-fix-deprecation-warning-in-integration-test.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0029-daemon-print-the-filename-when-the-config-file-is-mi.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0030-daemon-fix-self-test-config-file-location-for-newer.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0031-rules-fix-distcheck-ing-not-being-able-to-install-ud.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0032-etc-change-the-default-low-battery-policy.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.4-0033-etc-update-ignorelid-documentation.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.4-0034-daemon-lower-the-warning-levels-for-input-devices.patch
	eapply "${FILESDIR}"/${PN}-0.99.4-0035-released-upower-0-99-4.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0001-trivial-post-release-version-bump.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0002-update-readme.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.5-0003-daemon-fix-get-critical-action.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0004-lib-add-proper-error-and-cancellable-handling-to-upc.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0005-up-tool-exit-early-when-connecting-to-upower-fails.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0006-lib-remove-hidden-singleton-instance.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0007-upkbdbacklight-don-t-cache-the-brightness-level-alwa.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0008-upkbdbacklight-don-t-check-the-end-value-when-using.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.5-0009-build-fix-wformat-y2k-compilation-errors.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0010-linux-name-the-idevice-start-poll-timeout.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0011-linux-add-better-debug-for-idevice-startup-poll.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0012-linux-lower-initial-power-usage-when-idevice-isn-t-a.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0013-daemon-remove-unused-test-declarations.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0014-linux-don-t-talk-to-hid-devices-ourselves.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0015-linux-move-declaration-of-variables-closer-to-use.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0016-linux-split-off-device-type-detection.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0017-linux-remove-unneeded-goto.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0018-linux-simplify-up-device-supply-guess-type.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0019-linux-parent-bluetooth-mouse-test-devices-properly.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0020-linux-add-test-without-the-mouse-legacy-node.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0021-linux-parent-the-keyboard-device-correctly-in-tests.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0022-linux-allow-running-upowerd-under-valgrind-in-tests.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0023-linux-always-stop-daemon-when-started-in-tests.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0024-linux-disable-crashing-test.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0025-linux-simplify-getting-the-device-type.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0026-linux-add-a-test-for-hid-devices.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0027-linux-add-a-serial-number-to-mouse-battery-test.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0028-linux-get-a-serial-number-for-device-batteries.patch

	if has_version '>=dev-util/umockdev-0.8.13'; then
		eapply "${FILESDIR}"/${PN}-0.99.5-0029-revert-linux-disable-crashing-test.patch
	fi

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.5-0030-upkbdbacklight-add-new-brightnesschangedwithsource-s.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0031-upkbdbacklight-allow-reading-from-alternate-fd-in-b.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0032-upkbdbacklight-send-notifications-about-hardware-bri.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.5-0033-integration-test-hid-mouse-is-a-mouse.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0034-linux-fix-compilation-warning.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.5-0035-daemon-fix-polling-helper-debug-output.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0036-device-remove-extraneous-linefeed-in-g-debug.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.5-0037-integration-test-use-dbusmock-to-mock-logind.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0038-integration-test-add-get-critical-action-test.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0039-integration-test-use-symbolic-names-for-device-types.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0040-linux-fix-critical-when-searching-for-sibling-device.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0041-integration-test-add-test-for-unparented-input-devic.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.5-0042-daemon-add-support-for-pausing-and-resuming-poll.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0043-linux-refresh-devices-after-waking-up-from-sleep.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0044-linux-use-inhibitor-lock-to-guard-poll-pausing.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.5-0045-integration-test-add-test-for-refresh-after-sleep.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0046-integration-test-check-nopollbatteries-is-followed.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0047-integration-test-enable-running-from-jhbuild.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0048-integration-test-fix-path-for-unparented-device.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0049-daemon-make-warning-levels-for-devices-inclusive.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0050-linux-add-support-for-capacity-level-attribute.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0051-lib-add-more-members-to-updevicelevel-struct.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.5-0052-all-add-batterylevel-property.patch
		eapply "${FILESDIR}"/${PN}-0.99.5-0053-daemon-move-a-number-of-constants-to-a-shared-file.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.5-0054-lib-simplify-string-checks.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0055-do-not-spin-in-a-loop-when-proc-timer-stats-cannot-b.patch
	eapply "${FILESDIR}"/${PN}-0.99.5-0056-released-upower-0-99-5.patch
	eapply "${FILESDIR}"/${PN}-0.99.6-0001-trivial-post-release-version-bump.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.6-0002-linux-correctly-close-inhibitor-fd.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.6-0003-linux-add-test-for-wireless-joypad-connected-via-usb.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.6-0004-lib-add-up-device-kind-gaming-input-for-gaming-devic.patch
		eapply "${FILESDIR}"/${PN}-0.99.6-0005-linux-detect-joysticks-as-gaming-input-devices.patch
		eapply "${FILESDIR}"/${PN}-0.99.6-0006-linux-move-function-to-prepare-for-new-use.patch
		eapply "${FILESDIR}"/${PN}-0.99.6-0007-linux-grab-model-name-from-device-if-unavailable-fro.patch
		eapply "${FILESDIR}"/${PN}-0.99.6-0008-lib-fix-api-docs-for-level-properties.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.6-0009-freebsd-fix-lid-detection-on-freebsd.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.6-0010-linux-don-t-throw-an-error-if-there-s-no-data-to-rea.patch
		eapply "${FILESDIR}"/${PN}-0.99.6-0011-linux-add-better-debug-to-sysfs-get-capacity-level.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.6-0012-hacking-mention-make-check-in-the-file.patch
	eapply "${FILESDIR}"/${PN}-0.99.6-0013-daemon-remove-install-section-comment.patch
	eapply "${FILESDIR}"/${PN}-0.99.6-0014-daemon-fix-crash-when-is-present-in-the-device-name.patch
	eapply "${FILESDIR}"/${PN}-0.99.6-0015-linux-add-test-for-crash-when-battery-has-funky-name.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.6-0016-daemon-only-reset-poll-if-warning-level-changed.patch
		eapply "${FILESDIR}"/${PN}-0.99.6-0017-daemon-move-two-functions-up.patch
		eapply "${FILESDIR}"/${PN}-0.99.6-0018-daemon-more-efficient-poll-resetting.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.6-0019-openbsd-remove-sensor-max-types-upper-bound.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.6-0020-revert-bug-99862-patchset.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.6-0021-released-upower-0-99-6.patch
	eapply "${FILESDIR}"/${PN}-0.99.7-0001-trivial-post-release-version-bump.patch
	eapply "${FILESDIR}"/${PN}-0.99.7-0002-daemon-fix-critical-action-after-resume-from-hiberna.patch
	eapply "${FILESDIR}"/${PN}-0.99.7-0003-linux-fix-compilation-with-libimobiledevice-git.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.7-0004-daemon-allow-to-be-replaced-via-replace-r.patch
		eapply "${FILESDIR}"/${PN}-0.99.7-0005-linux-remove-empty-api-docs.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.7-0006-linux-add-example-to-run-a-single-test.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.7-0007-linux-use-g-clear-object-when-possible.patch
		eapply "${FILESDIR}"/${PN}-0.99.7-0008-main-use-g-clear-object-when-possible.patch
		eapply "${FILESDIR}"/${PN}-0.99.7-0009-docs-better-documentation-for-the-batterylevel-prop.patch
		eapply "${FILESDIR}"/${PN}-0.99.7-0010-linux-add-support-for-bluetooth-le-device-batteries.patch
		eapply "${FILESDIR}"/${PN}-0.99.7-0011-linux-add-test-for-bluetooth-le-battery-support.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.7-0012-released-upower-0-99-7.patch
	eapply "${FILESDIR}"/${PN}-0.99.8-0001-trivial-post-release-version-bump.patch
	eapply "${FILESDIR}"/${PN}-0.99.8-0002-lib-fix-warnings-when-d-bus-related-properties-chang.patch
	eapply "${FILESDIR}"/${PN}-0.99.8-0003-linux-prevent-crash-after-attaching-an-apple-tv.patch
	eapply "${FILESDIR}"/${PN}-0.99.8-0004-linux-check-hasbattery-key-for-newer-ios-versions.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.8-0005-linux-fix-crash-if-logind-doesn-t-return-an-error.patch
		eapply "${FILESDIR}"/${PN}-0.99.8-0006-linux-fix-memory-leak-if-logind-returns-an-error.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.8-0007-linux-lower-severity-of-unhandled-action-messages.patch
	eapply "${FILESDIR}"/${PN}-0.99.8-0008-daemon-lock-down-systemd-service-file.patch
	eapply "${FILESDIR}"/${PN}-0.99.8-0009-lib-simplify-resource-destruction.patch
	eapply "${FILESDIR}"/${PN}-0.99.8-0010-linux-add-a-readme-with-a-couple-of-debugging-comman.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.8-0011-linux-add-support-for-unknown-capacity-level.patch
		eapply "${FILESDIR}"/${PN}-0.99.8-0012-daemon-add-battery-level-specific-icons.patch
		eapply "${FILESDIR}"/${PN}-0.99.8-0013-linux-add-a-test-for-logitech-hid-charging-states.patch
		eapply "${FILESDIR}"/${PN}-0.99.8-0014-lib-mention-that-battery-level-is-preferred-when-pre.patch
		eapply "${FILESDIR}"/${PN}-0.99.8-0015-lib-add-a-new-version-of-up-client-get-devices-which.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.8-0016-add-commitment-file-as-part-of-gpl-common-cure-right.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.8-0017-linux-better-error-reporting-from-sysfs-get-double-w.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.8-0018-linux-remove-extra-linefeed.patch
	eapply "${FILESDIR}"/${PN}-0.99.8-0019-linux-clean-up-after-running-test-suite-in-distcheck.patch
	eapply "${FILESDIR}"/${PN}-0.99.8-0020-build-add-ci.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.8-0021-linux-fix-possible-double-close-on-exit.patch
		eapply "${FILESDIR}"/${PN}-0.99.8-0022-linux-make-sure-unknown-poll-lasts-5-seconds.patch
		eapply "${FILESDIR}"/${PN}-0.99.8-0023-linux-detect-hardware-that-needs-more-polling-after.patch
		eapply "${FILESDIR}"/${PN}-0.99.8-0024-linux-refresh-for-5-seconds-after-plug-unplug-on-mac.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.8-0025-linux-add-test-for-macbook-uevent-behaviour.patch
	eapply "${FILESDIR}"/${PN}-0.99.8-0026-0-99-8.patch

	if use ck; then
		# From Funtoo:
		# 	https://bugs.funtoo.org/browse/FL-1329
		eapply "${FILESDIR}"/${PN}-0.99.2-restore-deprecated-code.patch

		# From Debian:
		#	https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718458
		#	https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718491
		eapply "${FILESDIR}"/${PN}-0.99.0-always-use-pm-utils-backend.patch

		if use integration-test; then
			# From UPower:
			# 	https://cgit.freedesktop.org/upower/commit/?id=720680d6855061b136ecc9ff756fb0cc2bc3ae2c
			eapply "${FILESDIR}"/${PN}-0.99.2-fix-integration-test.patch
		fi
	fi

	eapply_user

	eautoreconf
}

src_configure() {
	local backend

	if use kernel_linux ; then
		backend=linux
	elif use kernel_FreeBSD ; then
		backend=freebsd
	else
		backend=dummy
	fi

	local myeconfargs=(
		--disable-static
		--disable-tests
		--enable-man-pages
		--libexecdir="${EPREFIX%/}"/usr/lib/${PN}
		--localstatedir="${EPREFIX%/}"/var
		--with-backend=${backend}
		--with-html-dir="${EPREFIX%/}"/usr/share/doc/${PF}/html
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
		--with-systemdutildir="$(systemd_get_utildir)"
		$(use_enable ck deprecated)
		$(use_enable doc gtk-doc-html)
		$(use_enable introspection)
		$(use_with ios idevice)
	)
	xdg_environment_reset
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	if use doc; then
		insinto /usr/share/gtk-doc/html/UPower
		doins doc/html/*
		dosym /usr/share/gtk-doc/html/UPower /usr/share/doc/${PF}/html
	fi

	if use integration-test; then
		newbin src/linux/integration-test upower-integration-test
	fi

	keepdir /var/lib/upower #383091
	prune_libtool_files
}
