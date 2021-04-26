# Distributed under the terms of the GNU General Public License v2

# Until bug #537330 glib is a reverse dependency of pkgconfig and, then
# adding new dependencies end up making stage3 to grow. Every addition needs
# then to be think very closely.

EAPI="6"
PYTHON_COMPAT=( python2_7 )
# Completely useless with or without USE static-libs, people need to use
# pkg-config
GNOME2_LA_PUNT="yes"

inherit autotools bash-completion-r1 epunt-cxx flag-o-matic gnome2 libtool linux-info \
	multilib multilib-minimal pax-utils python-r1 toolchain-funcs versionator virtualx

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="https://www.gtk.org/"
SRC_URI="${SRC_URI}
	https://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz" # pkg.m4 for eautoreconf

LICENSE="LGPL-2.1+"
SLOT="2/42"
KEYWORDS="~*"

IUSE="dbus debug fam kernel_linux +mime selinux static-libs systemtap test utils xattr"
REQUIRED_USE="
	utils? ( ${PYTHON_REQUIRED_USE} )
	test? ( ${PYTHON_REQUIRED_USE} )
"

RESTRICT="!test? ( test )"

RDEPEND="
	!<dev-util/gdbus-codegen-${PV}
	>=virtual/libiconv-0-r1[${MULTILIB_USEDEP}]
	>=dev-libs/libffi-3.0.13-r1:=[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}]
	selinux? ( >=sys-libs/libselinux-2.2.2-r5[${MULTILIB_USEDEP}] )
	xattr? ( >=sys-apps/attr-2.4.47-r1[${MULTILIB_USEDEP}] )
	fam? ( >=virtual/fam-0-r1[${MULTILIB_USEDEP}] )
	utils? (
		${PYTHON_DEPS}
		>=dev-util/gdbus-codegen-${PV}[${PYTHON_USEDEP}]
		virtual/libelf:0=
	)
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.1.2
	>=dev-libs/libxslt-1.0
	>=sys-devel/gettext-0.11
	>=dev-util/gtk-doc-am-1.20
	systemtap? ( >=dev-util/systemtap-1.3 )
	test? (
		sys-devel/gdb
		${PYTHON_DEPS}
		>=dev-util/gdbus-codegen-${PV}[${PYTHON_USEDEP}]
		>=sys-apps/dbus-1.2.14 )
	!<dev-util/gtk-doc-1.15-r2
"
PDEPEND="!<gnome-base/gvfs-1.6.4-r990
	dbus? ( gnome-base/dconf )
	mime? ( x11-misc/shared-mime-info )
"
# shared-mime-info needed for gio/xdgmime, bug #409481
# dconf is needed to be able to save settings, bug #498436
# Earlier versions of gvfs do not work with glib

pkg_setup() {
	if use kernel_linux ; then
		CONFIG_CHECK="~INOTIFY_USER"
		if use test ; then
			CONFIG_CHECK="~IPV6"
			WARNING_IPV6="Your kernel needs IPV6 support for running some tests, skipping them."
		fi
		linux-info_pkg_setup
	fi
}

src_prepare() {
	# Prevent build failure in stage3 where pkgconfig is not available, bug #481056
	mv -f "${WORKDIR}"/pkg-config-*/pkg.m4 "${S}"/m4macros/ || die

	if use test; then
		# Disable tests requiring dev-util/desktop-file-utils when not installed, bug #286629, upstream bug #629163
		if ! has_version dev-util/desktop-file-utils ; then
			ewarn "Some tests will be skipped due dev-util/desktop-file-utils not being present on your system,"
			ewarn "think on installing it to get these tests run."
			sed -i -e "/appinfo\/associations/d" gio/tests/appinfo.c || die
			sed -i -e "/desktop-app-info\/default/d" gio/tests/desktop-app-info.c || die
			sed -i -e "/desktop-app-info\/fallback/d" gio/tests/desktop-app-info.c || die
			sed -i -e "/desktop-app-info\/lastused/d" gio/tests/desktop-app-info.c || die
		fi

		# gdesktopappinfo requires existing terminal (gnome-terminal or any
		# other), falling back to xterm if one doesn't exist
		if ! has_version x11-terms/xterm && ! has_version x11-terms/gnome-terminal ; then
			ewarn "Some tests will be skipped due to missing terminal program"
			sed -i -e "/appinfo\/launch/d" gio/tests/appinfo.c || die
		fi

		# Disable tests requiring dbus-python and pygobject; bugs #349236, #377549, #384853
		if ! has_version dev-python/dbus-python || ! has_version 'dev-python/pygobject:3' ; then
			ewarn "Some tests will be skipped due to dev-python/dbus-python or dev-python/pygobject:3"
			ewarn "not being present on your system, think on installing them to get these tests run."
			sed -i -e "/connection\/filter/d" gio/tests/gdbus-connection.c || die
			sed -i -e "/connection\/large_message/d" gio/tests/gdbus-connection-slow.c || die
			sed -i -e "/gdbus\/proxy/d" gio/tests/gdbus-proxy.c || die
			sed -i -e "/gdbus\/proxy-well-known-name/d" gio/tests/gdbus-proxy-well-known-name.c || die
			sed -i -e "/gdbus\/introspection-parser/d" gio/tests/gdbus-introspection.c || die
			sed -i -e "/g_test_add_func/d" gio/tests/gdbus-threading.c || die
			sed -i -e "/gdbus\/method-calls-in-thread/d" gio/tests/gdbus-threading.c || die
			# needed to prevent gdbus-threading from asserting
			ln -sfn $(type -P true) gio/tests/gdbus-testserver.py
		fi

		# Some tests need ipv6, upstream bug #667468
		# https://bugs.gentoo.org/508752
		if [[ ! -f /proc/net/if_inet6 ]]; then
			sed -i -e "/gdbus\/peer-to-peer/d" gio/tests/gdbus-peer.c || die
			sed -i -e "/gdbus\/delayed-message-processing/d" gio/tests/gdbus-peer.c || die
			sed -i -e "/gdbus\/nonce-tcp/d" gio/tests/gdbus-peer.c || die
		fi

		# This test is prone to fail, bug #504024, upstream bug #723719
		sed -i -e '/gdbus-close-pending/d' gio/tests/Makefile.am || die
	else
		# Don't build tests, also prevents extra deps, bug #512022
		sed -i -e 's/ tests//' {.,gio,glib}/Makefile.am || die
	fi

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/682bca095068d2823a129bebae42bb4f27f3e118
	# 	https://gitlab.gnome.org/GNOME/glib/commit/3b4cb28e17c6a5dac64eb8afda2b1143757ad7a4
	# 	https://gitlab.gnome.org/GNOME/glib/commit/f3c604d2735fd63c5d45ecbeff9cb0e90d3356ac
	# 	https://gitlab.gnome.org/GNOME/glib/commit/d95bb1f08b07c3ae701076cd9d3cf6894a122e9c
	# 	https://gitlab.gnome.org/GNOME/glib/commit/6d55189d8c7eaf95b7d94d62b6e88caccaa4034a
	# 	https://gitlab.gnome.org/GNOME/glib/commit/b69beff42691ef300b6829beb261ca4cdfff02be
	# 	https://gitlab.gnome.org/GNOME/glib/commit/93982d4a16d8623137177da2f994abaf8075b4b0
	# 	https://gitlab.gnome.org/GNOME/glib/commit/9d0389b3b574e6e0fc181ac161bf7c9ccd231e15
	# 	https://gitlab.gnome.org/GNOME/glib/commit/b5e1ea6fee6ac5b97585ffc1e30eb4f1ec137e1f
	# 	https://gitlab.gnome.org/GNOME/glib/commit/2596919c58a364243196e65a9adda693448139f7
	# 	https://gitlab.gnome.org/GNOME/glib/commit/663834671dd34e95f7dbb6b96bebf1daac468c93
	# 	https://gitlab.gnome.org/GNOME/glib/commit/3d5de34def8b3120190ffb2561b5093abb6a3abb
	# 	https://gitlab.gnome.org/GNOME/glib/commit/8ea414c8c6c40e208ebe4a9fdd41c7abdb05c392
	# 	https://gitlab.gnome.org/GNOME/glib/commit/e2f8afdd85c18c6eea4ce42b0c9dad2cdbfc9b3e
	# 	https://gitlab.gnome.org/GNOME/glib/commit/407adc6ea12e08950b36722b95fa54ef925de53a
	# 	https://gitlab.gnome.org/GNOME/glib/commit/08f7f976961ca1174d187a917ec2a3d235f09448
	# 	https://gitlab.gnome.org/GNOME/glib/commit/57a49f6891a0d69c0b3b686040bf81e303831b77
	# 	https://gitlab.gnome.org/GNOME/glib/commit/ccf696a6e1da37ed414f08edb745a99aba935211
	# 	https://gitlab.gnome.org/GNOME/glib/commit/696db7561560d9311dca93f0c849f96770f41d01
	# 	https://gitlab.gnome.org/GNOME/glib/commit/6161b285da3d00fb4e02d4774d741799b6e18584
	# 	https://gitlab.gnome.org/GNOME/glib/commit/3f3eac474b26d5e01fbfdb50f3e45b7f7826bad9
	# 	https://gitlab.gnome.org/GNOME/glib/commit/26af7c152f602896cabf9ab6cb6ba42a47a5b992
	# 	https://gitlab.gnome.org/GNOME/glib/commit/2b536d3cbb718e9cf731bf07df96738341540701
	# 	https://gitlab.gnome.org/GNOME/glib/commit/c1b0f178ca4739e7ab2e4e47c4585d41db8637e5
	# 	https://gitlab.gnome.org/GNOME/glib/commit/caf9db2dfbea4fd0306d4edf12b11ee91d235c7c
	# 	https://gitlab.gnome.org/GNOME/glib/commit/d4791bd383189f4ea056e4f2aa0c90171bf7a6be
	# 	https://gitlab.gnome.org/GNOME/glib/commit/3d39b8eb01aa5590865691a303ee9153b2a35cf5
	# 	https://gitlab.gnome.org/GNOME/glib/commit/b5538416c065bafe760220e92754f891abd254b2
	# 	https://gitlab.gnome.org/GNOME/glib/commit/d0105f1c0845c1244c8419d0bb24c6f64ac9015f
	# 	https://gitlab.gnome.org/GNOME/glib/commit/1b348a876f84342bb3a197fadd249f8ce95abfeb
	# 	https://gitlab.gnome.org/GNOME/glib/commit/0550708ca7b615ab9e0df96ded43d18653f33ac2
	# 	https://gitlab.gnome.org/GNOME/glib/commit/3ffed912c19c5c24b7302d2ff12f82a6167f1c30
	# 	https://gitlab.gnome.org/GNOME/glib/commit/9348af3651afbd554fec35e556cda8add48bd9f8
	eapply "${FILESDIR}"/${PN}-2.43.0-add-version-macros-for-2-44.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gtype-add-type-declaration-macros-for-headers.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-g-declare-derived-type-allow-forward-declarations.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gsettings-add-g-settings-schema-key-get-name.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gsettings-add-g-settings-schema-list-children.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-add-glistmodel.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-giotypefuncs-test-tweak-get-type-regexp.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-g-declare-final-type-trivial-fix-in-docs-comment.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-declare-type-ignore-deprecations-in-inlines.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-macros-add-support-for-gnuc-cleanup-attribute.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-glib-add-support-for-g-auto-and-g-autoptr.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gobject-add-support-for-g-auto-and-g-autoptr.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-g-declare-type-add-auto-cleanup-support.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gio-add-support-for-g-auto-and-g-autoptr.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gobject-gtype-h-make-up-for-missing.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-docs-link-the-glistmodel-docs-from-the-index.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-fix-g-define-auto-cleanup-free-func-on-non-gcc.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-glistmodel-h-fix-glistmodelinterface-define.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gmacros-h-add-private-macro-glib-define-autoptr-chainup.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gtype-h-fix-build-on-non-gcc.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gliststore-add-sorted-insert-function.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-tests-add-test-for-gliststore-inserted-sort.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-docs-fix-typos-in-g-declare-type.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gliststore-fix-preconditions-in-insert-sorted.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-doc-fix-glistmodel-gliststore.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-doc-fix-g-auto-and-g-autoptr-typo.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-add-g-declare-interface.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-glistmodel-use-g-declare-interface.patch
	eapply "${FILESDIR}"/${PN}-2.43.91-add-g-autofree.patch
	eapply "${FILESDIR}"/${PN}-2.43.91-autocleanups-remove-g-autoptrgchar.patch
	eapply "${FILESDIR}"/${PN}-2.43.91-tests-add-many-autoptr-tests.patch
	eapply "${FILESDIR}"/${PN}-2.46.0-doc-small-clarification-in-g-autoptr.patch
	eapply "${FILESDIR}"/${PN}-2.46.1-doc-g-autoptrgchar-has-been-replaced-by-g-autofree.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/71944b1bfd2cff57e889b806d001458dce6fa2b5
	# 	https://gitlab.gnome.org/GNOME/glib/commit/7f2f4ab12df6ddb501900846896f496520871d16
	eapply "${FILESDIR}"/${PN}-2.43.2-gstrfuncs-add-g-strv-contains.patch
	eapply "${FILESDIR}"/${PN}-2.43.2-use-the-new-g-strv-contains.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/ed68d80e61b60833c15b69e57117e7f267757632
	# 	https://gitlab.gnome.org/GNOME/glib/commit/8d08b821090d5394175c17f375a192bb3f824c0c
	# 	https://gitlab.gnome.org/GNOME/glib/commit/485a6900fcd481f0899e4a775c96d5a34b62cb90
	# 	https://gitlab.gnome.org/GNOME/glib/commit/53abf0dc7d22d8a150fdc6162ef212cb5aa87c2f
	# 	https://gitlab.gnome.org/GNOME/glib/commit/f8da414d089057f63cb277af575675deb63536b0
	# 	https://gitlab.gnome.org/GNOME/glib/commit/169eae47e519068a0afa2ec44b24b884214d79ec
	# 	https://gitlab.gnome.org/GNOME/glib/commit/74c22150cf4c2f8a9c7d7fae058a7fd589a94a27
	eapply "${FILESDIR}"/${PN}-2.43.2-gio-correct-the-available-in-for-gnetworkmonitor.patch
	eapply "${FILESDIR}"/${PN}-2.43.2-gio-add-network-connectivity-state-to-gnetworkmonitor.patch
	eapply "${FILESDIR}"/${PN}-2.43.2-gio-add-gnetworkmonitor-impl-based-on-networkmanager.patch
	eapply "${FILESDIR}"/${PN}-2.43.2-updated-potfiles-in.patch
	eapply "${FILESDIR}"/${PN}-2.43.2-gio-fix-the-since-available-version-on-network-connectivity-stuff.patch
	eapply "${FILESDIR}"/${PN}-2.43.2-gio-add-missing-symbols-to-docs.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-docs-fix-up-docs-issues-in-gio.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/e668796c5a90a19bce0ff893794817af6aad4dc2
	# 	https://gitlab.gnome.org/GNOME/glib/commit/aa68b3d6d6f6d6c51e753b26b0fdc67b0eeefa17
	# 	https://gitlab.gnome.org/GNOME/glib/commit/0110f2a810cfd638a0a6525deb69aeec7a0f0cab
	# 	https://gitlab.gnome.org/GNOME/glib/commit/433fc9475d351f3529bea0ea18a443eb5ec7f3dc
	# 	https://gitlab.gnome.org/GNOME/glib/commit/6fffce2588b19e5c80915cc9f713fc51d6dd3879
	# 	https://gitlab.gnome.org/GNOME/glib/commit/97d24b93ab05762ec53785b5ec1c68e8d660b054
	# 	https://gitlab.gnome.org/GNOME/glib/commit/ade324f6fa6274fd2a925b4c8f9cb0ee4956a27f
	# 	https://gitlab.gnome.org/GNOME/glib/commit/1a6be022600550272638e858a7fbef5e57ce45ba
	# 	https://gitlab.gnome.org/GNOME/glib/commit/f9a9902aac826ab4aecc25f6eb533a418a4fa559
	# 	https://gitlab.gnome.org/GNOME/glib/commit/4c621fb7eeadb389c22c8ad17f736c70d56ee3e0
	# 	https://gitlab.gnome.org/GNOME/glib/commit/2e9c31af11b7d2d18052d5bbcdc3611f2f7480f5
	eapply "${FILESDIR}"/${PN}-2.43.4-add-new-api-g-steal-pointer.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-tests-add-a-test-case-for-g-steal-pointer.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-g-steal-pointer-make-it-c-clean.patch
	eapply "${FILESDIR}"/${PN}-2.43.4-gmem-h-gthread-h-include-glib-gutils-h.patch
	eapply "${FILESDIR}"/${PN}-2.43.92-docs-clean-up-a-few-glib-issues.patch
	eapply "${FILESDIR}"/${PN}-2.55.1-glib-fix-strict-aliasing-warnings-with-g-clear-pointer.patch
	eapply "${FILESDIR}"/${PN}-2.55.1-build-enable-fno-strict-aliasing.patch
	eapply "${FILESDIR}"/${PN}-2.57.2-gmem-h-use-typeof-in-g-steal-pointer-macro.patch
	eapply "${FILESDIR}"/${PN}-2.57.2-gmem-h-use-typeof-in-the-g-clear-pointer-macro.patch
	eapply "${FILESDIR}"/${PN}-2.57.2-gmacros-add-new-private-g-has-typeof-to-abstract-typeof-checks.patch
	eapply "${FILESDIR}"/${PN}-2.57.3-gmem-only-evaluate-pointer-argument-to-g-clear-pointer-once.patch

	# From glib-2.44.1.tar.xz:
	# 	Prevent build failure due to missing (generated) declarations
	eapply "${FILESDIR}"/${PN}-2.44.1-gio-gioenumtypes-network-connectivity-stuff.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/ed4a742946374f7ee3c46b93eb943c95f04ec4c4
	eapply "${FILESDIR}"/${PN}-2.43.92-http-proxy-support.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/d0219f25970c740ac1a8965754868d54bcd90eeb
	# 	https://gitlab.gnome.org/GNOME/glib/commit/7dd9ffbcfff3561d2d1bcd247c052e4c4399623f
	eapply "${FILESDIR}"/${PN}-2.47.2-glib-add-bounds-checked-unsigned-int-arithmetic.patch
	eapply "${FILESDIR}"/${PN}-2.47.2-tests-test-bounds-checked-int-arithmetic.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/1a2a689deacaac32b351ae97b00d8c35a6499cf6
	# 	https://gitlab.gnome.org/GNOME/glib/commit/15c5e643c64b5f428fdbb515625dd6e939dcd40b
	# 	https://gitlab.gnome.org/GNOME/glib/commit/b36b4941a634af096d21f906caae25ef35161166
	# 	https://gitlab.gnome.org/GNOME/glib/commit/0bfbb0d257593b2fcfaaf9bf09c586057ecfac25
	# 	https://gitlab.gnome.org/GNOME/glib/commit/9834f79279574e2cddc4dcb6149da9bd782dd40d
	# 	https://gitlab.gnome.org/GNOME/glib/commit/db2367e8782d7a39fc3e93d13f6a16f10cad04c2
	# 	https://gitlab.gnome.org/GNOME/glib/commit/ba12fbf8f8861e634def9fc0fb5e9ea603269803
	# 	https://gitlab.gnome.org/GNOME/glib/commit/f2fb877ef796c543f8ca166c7e05a434f163faf7
	eapply "${FILESDIR}"/${PN}-2.43.2-doc-glib-fix-all-undocumented-unused-undeclared-symbols.patch
	eapply "${FILESDIR}"/${PN}-2.45.1-gversionmacros-add-2-46-version-macros.patch
	eapply "${FILESDIR}"/${PN}-2.47.1-glib-add-2-48-availibity-macros.patch
	eapply "${FILESDIR}"/${PN}-2.47.2-gtrashstack-uninline-and-deprecate.patch
	eapply "${FILESDIR}"/${PN}-2.47.2-gutils-clean-up-bit-funcs-inlining-mess.patch
	eapply "${FILESDIR}"/${PN}-2.47.2-glib-clean-up-the-inline-mess-once-and-for-all.patch
	eapply "${FILESDIR}"/${PN}-2.47.3-gutils-g-bit-inlines-add-visibility-macros.patch
	eapply "${FILESDIR}"/${PN}-2.47.4-glibconfig-h-win32-in-remove-g-can-inline.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/ec6971b864a3faffadd0bf4a87c7c1b47697fc83
	eapply "${FILESDIR}"/${PN}-2.47.4-gtypes-h-move-g-static-assert-to-function-scope.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/aead1c046dd39748cca449b55ec300ba5f025365
	eapply "${FILESDIR}"/${PN}-2.47.92-gvariant-text-fix-scan-of-positional-parameters.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/f9d9f9c056d96eccbb75dcbdef2b58f6d2a3edea
	# 	https://gitlab.gnome.org/GNOME/glib/commit/3624e70508d414ae734c0b51f81839f8b5b1c809
	# 	https://gitlab.gnome.org/GNOME/glib/commit/61136c2c7333a937adb20a4a43f32e66bf89c2f5
	# 	https://gitlab.gnome.org/GNOME/glib/commit/c7f46997351805e436803ac74a49a88aa1602579
	# 	https://gitlab.gnome.org/GNOME/glib/commit/ba18667bb467ef4734f5d8a9bbeabcad39be4ecc
	# 	https://gitlab.gnome.org/GNOME/glib/commit/1ff79690fbd57a1029918ff37b7890b1096854b6
	# 	https://gitlab.gnome.org/GNOME/glib/commit/0d1eecddd4a87f4fcf6273e0ca95f11019582778
	# 	https://gitlab.gnome.org/GNOME/glib/commit/4e1567a079c13036320802f49ee8f78f78d0273a
	# 	https://gitlab.gnome.org/GNOME/glib/commit/8e23a514b02c67104f03545dec58116f00087229
	# 	https://gitlab.gnome.org/GNOME/glib/commit/8e8f4e6486c1578ae15d63835acd06f237324a6d
	# 	https://gitlab.gnome.org/GNOME/glib/commit/c79c234c352ff748056a30da6d4a49de0d2f878d
	# 	https://gitlab.gnome.org/GNOME/glib/commit/359b27d441a4dd701260d041e633e7241c314627
	eapply "${FILESDIR}"/${PN}-2.47.1-update-to-unicode-8-0.patch
	eapply "${FILESDIR}"/${PN}-2.47.1-update-unicode-test-data-for-unicode-8.patch
	eapply "${FILESDIR}"/${PN}-2.47.4-trivial-doc-comment-fix.patch
	eapply "${FILESDIR}"/${PN}-2.50.1-unicode-update-break-mappings.patch
	eapply "${FILESDIR}"/${PN}-2.50.1-unicode-update-to-unicode-9-0-0.patch
	eapply "${FILESDIR}"/${PN}-2.50.1-unicode-update-test-data-files-for-unicode-9-0-0.patch
	eapply "${FILESDIR}"/${PN}-2.50.1-unicode-fix-ordering-in-iso15924-tags-to-match-gunicodescript-enum.patch
	eapply "${FILESDIR}"/${PN}-2.53.4-unicode-update-to-unicode-10-0-0.patch
	eapply "${FILESDIR}"/${PN}-2.53.4-unicode-update-test-data-files-for-unicode-10-0-0.patch
	eapply "${FILESDIR}"/${PN}-2.55.0-docs-fix-various-minor-syntax-errors-in-gtk-doc-comments.patch
	eapply "${FILESDIR}"/${PN}-2.57.2-unicode-update-to-unicode-11-0-0.patch
	eapply "${FILESDIR}"/${PN}-2.57.2-unicode-update-test-data-files-for-unicode-11-0-0.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/e4aaae4ed689669a8530d0b79d4523eeb12554ad
	# 	https://gitlab.gnome.org/GNOME/glib/commit/67ce53058102905ac3c8f6f57b044616301d479b
	# 	https://gitlab.gnome.org/GNOME/glib/commit/aebcb15a9b9881b3a06c7db1a9674e6cc1b77e84
	# 	https://gitlab.gnome.org/GNOME/glib/commit/4fe89b0437db0a4997d548929eec07b8c579fff2
	# 	https://gitlab.gnome.org/GNOME/glib/commit/e8222c334318a2fce87a32bcd321580623eb00be
	eapply "${FILESDIR}"/${PN}-2.49.1-glib-add-2-50-availibity-macros.patch
	eapply "${FILESDIR}"/${PN}-2.51.0-add-version-macros-for-2-52.patch
	eapply "${FILESDIR}"/${PN}-2.53.0-gversionmacros-add-version-macros-for-glib-2-54.patch
	eapply "${FILESDIR}"/${PN}-2.53.2-gstrfuncs-add-replacement-for-string-to-number-functions.patch
	eapply "${FILESDIR}"/${PN}-2.53.2-gstrfuncs-fix-translation-issues.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/merge_requests/411
	# 	https://www.openwall.com/lists/oss-security/2018/10/23/5
	eapply "${FILESDIR}"/${PN}-2.42.2-various-gvariant-gmarkup-and-gdbus-fuzzing-fixes.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/d8f8f4d637ce43f8699ba94c9b7648beda0ca174 (CVE-2019-12450)
	eapply "${FILESDIR}"/${PN}-2.61.1-gfile-limit-access-to-files-when-copying.patch

	# gdbus-codegen is a separate package
	eapply "${FILESDIR}"/${PN}-2.40.0-external-gdbus-codegen.patch

	# Leave python shebang alone - handled by python_replicate_script
	# We could call python_setup and give configure a valid --with-python
	# arg, but that would mean a build dep on python when USE=utils.
	sed -e '/${PYTHON}/d' \
		-i glib/Makefile.{am,in} || die

	# Gentoo handles completions in a different directory
	sed -i "s|^completiondir =.*|completiondir = $(get_bashcompdir)|" \
		gio/Makefile.am || die

	# Prevent m4_copy error when running aclocal
	# m4_copy: won't overwrite defined macro: glib_DEFUN
	sed -e "s/m4_copy/m4_copy_force/" \
		-i m4macros/glib-gettext.m4 || die

	# Also needed to prevent cross-compile failures, see bug #267603
	eautoreconf

	gnome2_src_prepare

	epunt_cxx
}

multilib_src_configure() {
	# Avoid circular depend with dev-util/pkgconfig and
	# native builds (cross-compiles won't need pkg-config
	# in the target ROOT to work here)
	if ! tc-is-cross-compiler && ! $(tc-getPKG_CONFIG) --version >& /dev/null; then
		if has_version sys-apps/dbus; then
			export DBUS1_CFLAGS="-I/usr/include/dbus-1.0 -I/usr/$(get_libdir)/dbus-1.0/include"
			export DBUS1_LIBS="-ldbus-1"
		fi
		export LIBFFI_CFLAGS="-I$(echo /usr/$(get_libdir)/libffi-*/include)"
		export LIBFFI_LIBS="-lffi"
	fi

	local myconf

	case "${CHOST}" in
		*-mingw*) myconf="${myconf} --with-threads=win32" ;;
		*)        myconf="${myconf} --with-threads=posix" ;;
	esac

	# Always use internal libpcre, bug #254659
	# libelf used only by the gresource bin
	ECONF_SOURCE="${S}" gnome2_src_configure ${myconf} \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable xattr) \
		$(use_enable fam) \
		$(use_enable selinux) \
		$(use_enable static-libs static) \
		$(use_enable systemtap dtrace) \
		$(use_enable systemtap systemtap) \
		$(multilib_native_use_enable utils libelf) \
		--disable-compile-warnings \
		--enable-man \
		--with-pcre=internal \
		--with-xml-catalog="${EPREFIX}/etc/xml/catalog"

	if multilib_is_native_abi; then
		local d
		for d in glib gio gobject; do
			ln -s "${S}"/docs/reference/${d}/html docs/reference/${d}/html || die
		done
	fi
}

multilib_src_test() {
	export XDG_CONFIG_DIRS=/etc/xdg
	export XDG_DATA_DIRS=/usr/local/share:/usr/share
	export G_DBUS_COOKIE_SHA1_KEYRING_DIR="${T}/temp"
	export LC_TIME=C # bug #411967
	unset GSETTINGS_BACKEND # bug #596380
	python_setup

	# Related test is a bit nitpicking
	mkdir "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"
	chmod 0700 "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"

	# Hardened: gdb needs this, bug #338891
	if host-is-pax ; then
		pax-mark -mr "${BUILD_DIR}"/tests/.libs/assert-msg-test \
			|| die "Hardened adjustment failed"
	fi

	# Need X for dbus-launch session X11 initialization
	virtx emake check
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_install_all() {
	einstalldocs

	if use utils ; then
		python_replicate_script "${ED}"/usr/bin/gtester-report
	else
		rm "${ED}usr/bin/gtester-report"
		rm "${ED}usr/share/man/man1/gtester-report.1"
	fi

	# Do not install charset.alias even if generated, leave it to libiconv
	rm -f "${ED}/usr/lib/charset.alias"

	# Don't install gdb python macros, bug 291328
	rm -rf "${ED}/usr/share/gdb/" "${ED}/usr/share/glib-2.0/gdb/"
}

pkg_postinst() {
	gnome2_pkg_postinst
	if has_version '<x11-libs/gtk+-3.0.12:3'; then
		# To have a clear upgrade path for gtk+-3.0.x users, have to resort to
		# a warning instead of a blocker
		ewarn
		ewarn "Using <gtk+-3.0.12:3 with ${P} results in frequent crashes."
		ewarn "You should upgrade to a newer version of gtk+:3 immediately."
	fi
}
