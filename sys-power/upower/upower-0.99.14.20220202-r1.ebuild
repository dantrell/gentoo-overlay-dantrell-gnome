# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_8,3_9,3_10} )

inherit autotools python-single-r1 systemd xdg-utils

DESCRIPTION="D-Bus abstraction for enumerating power devices, listening to device events, querying history and statistics"
HOMEPAGE="https://upower.freedesktop.org/"
SRC_URI="https://${PN}.freedesktop.org/releases/${PN}-0.99.3.tar.xz"

LICENSE="GPL-2"
SLOT="0/3" # based on SONAME of libupower-glib.so
KEYWORDS="*"

IUSE="ck doc integration-test +introspection ios selinux"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	>=dev-libs/dbus-glib-0.100
	>=dev-libs/glib-2.34:2
	dev-util/gdbus-codegen
	sys-apps/dbus:=
	>=sys-auth/polkit-0.110
	ck? (
		sys-power/acpid
		sys-power/pm-utils
	)
	integration-test? (
		$(python_gen_cond_dep '
			dev-python/python-dbusmock[${PYTHON_USEDEP}]
		')
		dev-util/umockdev
	)
	introspection? ( dev-libs/gobject-introspection:= )
	kernel_linux? (
		virtual/libusb:1
		dev-libs/libgudev:=
		virtual/udev
		ios? (
			>=app-pda/libimobiledevice-1:=
			>=app-pda/libplist-2:=
		)
	)
"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-devicekit )
"
BDEPEND="
	app-text/docbook-xsl-stylesheets
	dev-libs/gobject-introspection-common
	dev-libs/libxslt
	dev-util/gdbus-codegen
	dev-util/intltool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	doc? ( dev-util/gtk-doc )
"

QA_MULTILIB_PATHS="usr/lib/${PN}/.*"

S="${WORKDIR}/${PN}-0.99.3"

pkg_setup() {
	python-single-r1_pkg_setup
}

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

	eapply "${FILESDIR}"/${PN}-0.99.9-0001-build-gtk-doc-rebuild-types-and-sections.patch
	eapply "${FILESDIR}"/${PN}-0.99.9-0002-lib-work-around-to-fix-gtk-doc-s-type-detection.patch
	eapply "${FILESDIR}"/${PN}-0.99.9-0003-lib-use-see-also-instead-of-see-also.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.9-0004-lib-upclient-fix-stray.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.9-0005-lib-upclient-up-client-get-display-device-returns-a.patch
	eapply "${FILESDIR}"/${PN}-0.99.9-0006-daemon-fix-upower-not-having-access-to-udev-events.patch
	eapply "${FILESDIR}"/${PN}-0.99.9-0007-build-add-missing-python3-dbus-package-to-ci.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.9-0008-build-fix-out-of-tree-build.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.9-0009-test-fix-up-self-test-crash-during-out-of-tree-build.patch
	eapply "${FILESDIR}"/${PN}-0.99.9-0010-build-build-upower-out-of-tree.patch
	eapply "${FILESDIR}"/${PN}-0.99.9-0011-daemon-fix-upower-s-keyboard-backlight-support.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.9-0012-docs-mention-to-try-and-not-use-iconname-when-possib.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.9-0013-src-linux-up-device-hid-c-usage-code-is-defined-as-a.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.9-0014-build-fix-up-daemon-generated-h-not-being-found-on-d.patch
		eapply "${FILESDIR}"/${PN}-0.99.9-0015-doc-fix-dist-not-working.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.9-0016-ci-run-distcheck-as-a-test.patch
	eapply "${FILESDIR}"/${PN}-0.99.9-0017-0-99-9.patch
	eapply "${FILESDIR}"/${PN}-0.99.10-0001-daemon-make-comment-more-succinct.patch
	eapply "${FILESDIR}"/${PN}-0.99.10-0002-daemon-consider-pending-charge-when-calculating-the.patch
	eapply "${FILESDIR}"/${PN}-0.99.10-0003-integration-test-define-pending-charge-and-pending-d.patch
	eapply "${FILESDIR}"/${PN}-0.99.10-0004-integration-test-test-displaydevice-pending-charge.patch
	eapply "${FILESDIR}"/${PN}-0.99.10-0005-linux-don-t-set-out-state-before-state-is-final.patch
	eapply "${FILESDIR}"/${PN}-0.99.10-0006-linux-map-pending-charge-to-fully-charged-when-charg.patch
	eapply "${FILESDIR}"/${PN}-0.99.10-0007-integration-test-test-mapping-pending-charge-to-full.patch
	eapply "${FILESDIR}"/${PN}-0.99.10-0008-released-upower-0-99-10.patch
	eapply "${FILESDIR}"/${PN}-0.99.11-0001-trivial-post-release-version-bump.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.11-0002-replace-use-of-deprecated-g-type-class-add-private.patch
		eapply "${FILESDIR}"/${PN}-0.99.11-0003-replace-use-of-g-type-instance-get-private.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.11-0004-move-d-bus-policy-file-to-usr-share-dbus-1-system-d.patch
	eapply "${FILESDIR}"/${PN}-0.99.11-0005-let-systemd-create-var-lib-upower.patch
	eapply "${FILESDIR}"/${PN}-0.99.11-0006-harden-systemd-service.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.11-0007-docs-mention-that-not-all-batteries-are-laptop-batte.patch
		eapply "${FILESDIR}"/${PN}-0.99.11-0008-linux-don-t-treat-device-batteries-like-laptop-batte.patch
		eapply "${FILESDIR}"/${PN}-0.99.11-0009-linux-retry-to-get-a-battery-type-if-it-s-unknown.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.11-0010-linux-start-polling-for-unknown-device-batteries-too.patch
	eapply "${FILESDIR}"/${PN}-0.99.11-0011-linux-add-test-for-logitech-unknown-device-races.patch
	eapply "${FILESDIR}"/${PN}-0.99.11-0012-rules-split-off-hid-rules.patch
	eapply "${FILESDIR}"/${PN}-0.99.11-0013-rules-reduce-our-list-of-hid-devices.patch
	eapply "${FILESDIR}"/${PN}-0.99.11-0014-linux-add-gaming-input-type-to-the-test-suite.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.11-0015-linux-use-symbolic-names-for-device-types-in-test-su.patch
	fi

	#~eapply "${FILESDIR}"/${PN}-0.99.11-0016-build-migrate-from-intltool-to-gettext.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.11-0017-upkbdbacklight-fix-endless-loop-burning-100-cpu-on-k.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.11-0018-add-code-of-conduct-document.patch
	eapply "${FILESDIR}"/${PN}-0.99.11-0019-released-upower-0-99-11.patch
	eapply "${FILESDIR}"/${PN}-0.99.12-0001-trivial-post-release-version-bump.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.12-0002-linux-fix-memory-leak-in-bluez-backend.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0003-linux-fix-warning-when-bluez-appearance-property-isn.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0004-linux-remove-unused-code-in-test-suite.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0005-linux-add-test-for-appearance-property-being-missing.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0006-lib-add-pen-device-type.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0007-linux-detect-bluetooth-pens.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.12-0008-linux-identify-keyboard-pointing-device-combos-as-ke.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.12-0009-tests-add-a-keyboard-mouse-combo-device-test.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.12-0010-linux-add-support-for-iphone-xr-xs-models.patch
	eapply "${FILESDIR}"/${PN}-0.99.12-0011-build-use-a-newer-libplist-if-available.patch
	eapply "${FILESDIR}"/${PN}-0.99.12-0012-ci-force-building-with-libplist.patch
	eapply "${FILESDIR}"/${PN}-0.99.12-0013-linux-fix-umockdev-link-in-test.patch

	eapply "${FILESDIR}"/${PN}-0.99.12-0014-linux-clarify-upinput-device-handling.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.12-0015-linux-simplify-upinput-object-code.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0016-linux-remove-duplicate-header-in-up-input-c.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0017-linux-make-watched-switch-a-property-of-upinput.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0018-linux-remove-updaemon-dependency-from-upinput.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0019-linux-remove-unused-headers-in-up-input-c.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.12-0020-linux-remove-unneeded-header-from-up-input-h.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.12-0021-linux-fix-warning-when-compiling-with-meson.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.12-0022-linux-don-t-throw-debug-errors-unless-needed.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.12-0023-linux-add-support-for-running-under-umockdev.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0024-linux-fix-gudev-includes-for-upinput.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0025-lib-add-touchpad-device-type.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0026-linux-set-update-time-for-bluez-devices.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0027-linux-remove-support-for-csr-devices.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0028-build-remove-libusb-dependency-in-linux.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0029-lib-invert-percentage-conditional-in-device-to-text.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0030-lib-add-more-device-kinds-for-bluetooth-classes.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0031-linux-parse-kind-from-class-if-appearance-is-not-ava.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0032-tests-convert-unpacked-tuple-constants-to-range.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0033-tests-move-bluez-battery-setup-into-helper-function.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0034-tests-add-test-cases-for-bluetooth-device-classes.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0035-up-client-document-and-handle-null-return-when-getti.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0036-up-tool-catch-null-return-for-more-upower-api-calls.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0039-linux-add-property-to-ignore-the-capacity-sysfs-valu.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0040-linux-move-functions.patch
	fi

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.12-0041-linux-ignore-capacity-sysfs-on-macs.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0042-linux-simplify-is-macbook-function.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.12-0043-linux-fix-typo-in-test-comment.patch
	eapply "${FILESDIR}"/${PN}-0.99.12-0044-linux-use-existing-gudev-functions-in-watts-up-drive.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.12-0045-linux-use-new-uncached-sysfs-attr-gudev-api.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0046-linux-remove-sysfs-utils-helpers.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0047-linux-remove-user-space-support-for-logitech-unifyin.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0048-lib-add-up-device-kind-bluetooth-generic-type.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0049-linux-make-unknown-bluetooth-devices-appear-as-gener.patch
		eapply "${FILESDIR}"/${PN}-0.99.12-0051-data-also-remove-hid-udev-rules.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.12-0053-build-force-enable-introspection-for-make-distcheck.patch
	eapply "${FILESDIR}"/${PN}-0.99.12-0054-0-99-12.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.13-0001-linux-fix-0-01-w-energy-rate-readings-from-power-now.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.13-0002-tests-add-a-test-case-for-batteries-with-zero-power.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.13-0003-daemon-make-get-device-charge-icon-public.patch
		eapply "${FILESDIR}"/${PN}-0.99.13-0004-daemon-sync-icon-and-warning-for-non-default-low-lev.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.13-0005-tests-add-test-for-non-default-low-level.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.13-0006-device-don-t-update-properties-when-device-isn-t-exp.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.13-0007-etc-tweak-default-percentage-levels.patch
	eapply "${FILESDIR}"/${PN}-0.99.13-0008-linux-don-t-throw-away-large-but-possible-energy-rat.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.13-0009-linux-fix-touchpad-not-being-the-right-type.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.13-0010-linux-add-test-for-touchpads-being-tagged-as-mice.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.13-0011-build-require-new-gudev-to-fix-battery-detection.patch
		eapply "${FILESDIR}"/${PN}-0.99.13-0012-up-backend-add-inhibitor-lock-interface.patch
		eapply "${FILESDIR}"/${PN}-0.99.13-0013-up-daemon-prevent-suspending-for-critical-action.patch
		eapply "${FILESDIR}"/${PN}-0.99.13-0014-tests-test-inhibitor-lock-for-critical-action.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.13-0016-tests-run-test-suite-in-verbose-mode-by-default.patch
	eapply "${FILESDIR}"/${PN}-0.99.13-0017-0-99-13.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0001-lib-mark-lid-related-functions-and-properties-as-dep.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.14-0002-lib-mark-device-refresh-function-as-deprecated.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0004-readme-update-dependencies.patch
	#~eapply "${FILESDIR}"/${PN}-0.99.14-0005-build-remove-systemdutildir-option.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0006-build-remove-deprecated-option.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.14-0007-tests-return-77-when-skipping-tests.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0008-build-support-building-upower-with-meson.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0010-tools-include-top-level-library-include.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0012-meson-fix-header-source-extraction-from-gdbus-codege.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0013-meson-depend-on-upowerd-dbus-for-the-entire-daemon.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0014-build-clean-up-include-directories-usage.patch
	#~eapply "${FILESDIR}"/${PN}-0.99.14-0015-build-remove-autotools.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0016-etc-document-time-unit.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0017-linux-rename-integration-test-script.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0018-linux-split-the-integration-test-into-individual-tes.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0022-build-add-missing-glib-log-domains.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0023-build-require-gir-to-be-created-to-run-tests.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0024-linux-postpone-importing-libraries-for-tests.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0025-linux-bump-tests-timeout.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0028-build-remove-unused-variable-assignment.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0029-build-fix-idevice-support-always-being-off.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0030-all-remove-have-config-h-conditional.patch
	fi

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0031-linux-remove-unused-variable.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.14-0032-build-fix-compiling-with-idevice-disabled.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0033-build-fix-libplist-1-x-builds.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0034-dbus-add-chargecycles-property.patch
		eapply "${FILESDIR}"/${PN}-0.99.14-0035-lib-add-api-to-access-chargecyles-d-bus-property.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.14-0036-linux-export-charge-cycles-for-batteries-that-suppor.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0037-tests-add-chargecycles-test.patch

	eapply "${FILESDIR}"/${PN}-0.99.14-0039-linux-make-sure-chargecycles-is-unknown-in-more-case.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0040-linux-fix-bluetooth-tests-for-python-dbusmock-change.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.14-0041-linux-remember-if-a-ups-is-a-fake-ups.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0042-linux-only-try-to-open-a-device-if-it-s-not-a-fake-u.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0043-linux-fix-warning-when-using-fake-ups.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0044-lib-add-up-client-new-async.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.14-0045-tests-add-test-for-up-client-async-functions.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0046-lib-add-internal-helper-for-up-client-get-devices2.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.14-0047-linux-remove-libtool-support-from-test-suite.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0048-lib-implement-up-client-get-devices-async.patch
		eapply "${FILESDIR}"/${PN}-0.99.14-0049-up-daemon-fix-inhibitor-lock-leak.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.14-0050-linux-explicitly-recognize-usb-power-supplies.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0051-lib-remove-unnecessary-cast.patch
		eapply "${FILESDIR}"/${PN}-0.99.14-0052-lib-prepare-headers-for-internal-g-auto-usage.patch
		eapply "${FILESDIR}"/${PN}-0.99.14-0053-lib-simplify-loop-using-g-auto.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.14-0054-history-fix-time-compression-of-data-points.patch

	if ! use ck; then
		eapply "${FILESDIR}"/${PN}-0.99.14-0055-linux-make-test-compatible-with-older-dbusmock-versi.patch
		eapply "${FILESDIR}"/${PN}-0.99.14-0056-history-delay-saving-history-even-on-low-power.patch
	fi

	eapply "${FILESDIR}"/${PN}-0.99.14-0057-history-remove-unused-and-bogus-define.patch
	eapply "${FILESDIR}"/${PN}-0.99.14-0058-release-0-99-14.patch

	if use ck; then
		# From Funtoo:
		# 	https://bugs.funtoo.org/browse/FL-1329
		eapply "${FILESDIR}"/${PN}-0.99.14-restore-deprecated-code.patch

		# From Debian:
		#	https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718458
		#	https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718491
		eapply "${FILESDIR}"/${PN}-0.99.0-always-use-pm-utils-backend.patch

		if use integration-test; then
			# From UPower:
			# 	https://cgit.freedesktop.org/upower/commit/?id=720680d6855061b136ecc9ff756fb0cc2bc3ae2c
			eapply "${FILESDIR}"/${PN}-0.99.14-fix-integration-test.patch
		fi
	fi

	default
	xdg_environment_reset
	eautoreconf
}

src_configure() {
	local backend

	if use kernel_linux ; then
		backend=linux
	else
		backend=dummy
	fi

	local myeconfargs=(
		--disable-static
		--disable-tests
		--enable-man-pages
		--libexecdir="${EPREFIX}"/usr/lib/${PN}
		--localstatedir="${EPREFIX}"/var
		--with-backend=${backend}
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
		--with-systemdutildir="$(systemd_get_utildir)"
		$(use_enable ck deprecated)
		$(use_enable doc gtk-doc-html)
		$(use_enable introspection)
		$(use_with ios idevice)
	)
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
		newbin src/linux/integration-test.py upower-integration-test
	fi

	find "${ED}" -type f -name '*.la' -delete || die
	keepdir /var/lib/upower #383091
}

pkg_postinst() {
	if [[ ${REPLACING_VERSIONS} ]] && ver_test ${REPLACING_VERSIONS} -lt 0.99.12; then
		elog "Support for Logitech Unifying Receiver battery state readout was"
		elog "removed in version 0.99.12, these devices have been directly"
		elog "supported by the Linux kernel since version >=3.2."
		elog
		elog "Support for CSR devices battery state was removed from udev rules"
		elog "in version 0.99.12. This concerns the following Logitech products"
		elog "from the mid 2000s:"
		elog "Mouse/Dual/Keyboard+Mouse Receiver, Freedom Optical, Elite Duo,"
		elog "MX700/MX1000, Optical TrackMan, Click! Mouse, Presenter."
	fi
}
