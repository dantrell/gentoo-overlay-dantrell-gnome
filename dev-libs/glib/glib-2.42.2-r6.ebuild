# Distributed under the terms of the GNU General Public License v2

# Until bug #537330 glib is a reverse dependency of pkgconfig and, then
# adding new dependencies end up making stage3 to grow. Every addition needs
# then to be think very closely.

EAPI="5"
PYTHON_COMPAT=( python2_7 )
# Building with --disable-debug highly unrecommended.  It will build glib in
# an unusable form as it disables some commonly used API.  Please do not
# convert this to the use_enable form, as it results in a broken build.
GCONF_DEBUG="yes"
# Completely useless with or without USE static-libs, people need to use
# pkg-config
GNOME2_LA_PUNT="yes"

inherit autotools bash-completion-r1 gnome2 libtool epatch epunt-cxx flag-o-matic multilib \
	pax-utils python-r1 toolchain-funcs versionator virtualx linux-info multilib-minimal

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="https://www.gtk.org/"
SRC_URI="${SRC_URI}
	https://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz" # pkg.m4 for eautoreconf

LICENSE="LGPL-2.1+"
SLOT="2/42"
KEYWORDS="*"

IUSE="dbus fam kernel_linux +mime selinux static-libs systemtap test utils xattr"
REQUIRED_USE="
	utils? ( ${PYTHON_REQUIRED_USE} )
	test? ( ${PYTHON_REQUIRED_USE} )
"

RDEPEND="
	!<dev-util/gdbus-codegen-${PV}
	>=virtual/libiconv-0-r1[${MULTILIB_USEDEP}]
	>=virtual/libffi-3.0.13-r1[${MULTILIB_USEDEP}]
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
	# 	https://git.gnome.org/browse/glib/commit/?id=682bca095068d2823a129bebae42bb4f27f3e118
	# 	https://git.gnome.org/browse/glib/commit/?id=3b4cb28e17c6a5dac64eb8afda2b1143757ad7a4
	# 	https://git.gnome.org/browse/glib/commit/?id=f3c604d2735fd63c5d45ecbeff9cb0e90d3356ac
	# 	https://git.gnome.org/browse/glib/commit/?id=d95bb1f08b07c3ae701076cd9d3cf6894a122e9c
	# 	https://git.gnome.org/browse/glib/commit/?id=6d55189d8c7eaf95b7d94d62b6e88caccaa4034a
	# 	https://git.gnome.org/browse/glib/commit/?id=b69beff42691ef300b6829beb261ca4cdfff02be
	# 	https://git.gnome.org/browse/glib/commit/?id=93982d4a16d8623137177da2f994abaf8075b4b0
	# 	https://git.gnome.org/browse/glib/commit/?id=9d0389b3b574e6e0fc181ac161bf7c9ccd231e15
	# 	https://git.gnome.org/browse/glib/commit/?id=b5e1ea6fee6ac5b97585ffc1e30eb4f1ec137e1f
	# 	https://git.gnome.org/browse/glib/commit/?id=2596919c58a364243196e65a9adda693448139f7
	# 	https://git.gnome.org/browse/glib/commit/?id=663834671dd34e95f7dbb6b96bebf1daac468c93
	# 	https://git.gnome.org/browse/glib/commit/?id=3d5de34def8b3120190ffb2561b5093abb6a3abb
	# 	https://git.gnome.org/browse/glib/commit/?id=8ea414c8c6c40e208ebe4a9fdd41c7abdb05c392
	# 	https://git.gnome.org/browse/glib/commit/?id=e2f8afdd85c18c6eea4ce42b0c9dad2cdbfc9b3e
	# 	https://git.gnome.org/browse/glib/commit/?id=407adc6ea12e08950b36722b95fa54ef925de53a
	# 	https://git.gnome.org/browse/glib/commit/?id=08f7f976961ca1174d187a917ec2a3d235f09448
	# 	https://git.gnome.org/browse/glib/commit/?id=57a49f6891a0d69c0b3b686040bf81e303831b77
	# 	https://git.gnome.org/browse/glib/commit/?id=ccf696a6e1da37ed414f08edb745a99aba935211
	# 	https://git.gnome.org/browse/glib/commit/?id=696db7561560d9311dca93f0c849f96770f41d01
	# 	https://git.gnome.org/browse/glib/commit/?id=6161b285da3d00fb4e02d4774d741799b6e18584
	# 	https://git.gnome.org/browse/glib/commit/?id=3f3eac474b26d5e01fbfdb50f3e45b7f7826bad9
	# 	https://git.gnome.org/browse/glib/commit/?id=26af7c152f602896cabf9ab6cb6ba42a47a5b992
	# 	https://git.gnome.org/browse/glib/commit/?id=2b536d3cbb718e9cf731bf07df96738341540701
	# 	https://git.gnome.org/browse/glib/commit/?id=c1b0f178ca4739e7ab2e4e47c4585d41db8637e5
	# 	https://git.gnome.org/browse/glib/commit/?id=caf9db2dfbea4fd0306d4edf12b11ee91d235c7c
	# 	https://git.gnome.org/browse/glib/commit/?id=d4791bd383189f4ea056e4f2aa0c90171bf7a6be
	# 	https://git.gnome.org/browse/glib/commit/?id=3d39b8eb01aa5590865691a303ee9153b2a35cf5
	# 	https://git.gnome.org/browse/glib/commit/?id=b5538416c065bafe760220e92754f891abd254b2
	# 	https://git.gnome.org/browse/glib/commit/?id=d0105f1c0845c1244c8419d0bb24c6f64ac9015f
	# 	https://git.gnome.org/browse/glib/commit/?id=1b348a876f84342bb3a197fadd249f8ce95abfeb
	# 	https://git.gnome.org/browse/glib/commit/?id=0550708ca7b615ab9e0df96ded43d18653f33ac2
	# 	https://git.gnome.org/browse/glib/commit/?id=3ffed912c19c5c24b7302d2ff12f82a6167f1c30
	# 	https://git.gnome.org/browse/glib/commit/?id=9348af3651afbd554fec35e556cda8add48bd9f8
	epatch "${FILESDIR}"/${PN}-2.43.0-add-version-macros-for-2-44.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-gtype-add-type-declaration-macros-for-headers.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-g-declare-derived-type-allow-forward-declarations.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-gsettings-add-g-settings-schema-key-get-name.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-gsettings-add-g-settings-schema-list-children.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-add-glistmodel.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-giotypefuncs-test-tweak-get-type-regexp.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-g-declare-final-type-trivial-fix-in-docs-comment.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-declare-type-ignore-deprecations-in-inlines.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-macros-add-support-for-gnuc-cleanup-attribute.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-glib-add-support-for-g-auto-and-g-autoptr.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-gobject-add-support-for-g-auto-and-g-autoptr.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-g-declare-type-add-auto-cleanup-support.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-gio-add-support-for-g-auto-and-g-autoptr.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-gobject-gtype-h-make-up-for-missing.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-docs-link-the-glistmodel-docs-from-the-index.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-fix-g-define-auto-cleanup-free-func-on-non-gcc.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-glistmodel-h-fix-glistmodelinterface-define.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-gmacros-h-add-private-macro-glib-define-autoptr-chainup.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-gtype-h-fix-build-on-non-gcc.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-gliststore-add-sorted-insert-function.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-tests-add-test-for-gliststore-inserted-sort.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-docs-fix-typos-in-g-declare-type.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-gliststore-fix-preconditions-in-insert-sorted.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-doc-fix-glistmodel-gliststore.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-doc-fix-g-auto-and-g-autoptr-typo.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-add-g-declare-interface.patch
	epatch "${FILESDIR}"/${PN}-2.43.4-glistmodel-use-g-declare-interface.patch
	epatch "${FILESDIR}"/${PN}-2.43.91-add-g-autofree.patch
	epatch "${FILESDIR}"/${PN}-2.43.91-autocleanups-remove-g-autoptrgchar.patch
	epatch "${FILESDIR}"/${PN}-2.43.91-tests-add-many-autoptr-tests.patch
	epatch "${FILESDIR}"/${PN}-2.46.0-doc-small-clarification-in-g-autoptr.patch
	epatch "${FILESDIR}"/${PN}-2.46.1-doc-g-autoptrgchar-has-been-replaced-by-g-autofree.patch

	# From GNOME:
	# 	https://git.gnome.org/browse/glib/commit/?id=ed4a742946374f7ee3c46b93eb943c95f04ec4c4
	epatch "${FILESDIR}"/${PN}-2.43.92-http-proxy-support.patch

	# From GNOME:
	# 	https://git.gnome.org/browse/glib/commit/?id=d0219f25970c740ac1a8965754868d54bcd90eeb
	# 	https://git.gnome.org/browse/glib/commit/?id=7dd9ffbcfff3561d2d1bcd247c052e4c4399623f
	epatch "${FILESDIR}"/${PN}-2.47.2-glib-add-bounds-checked-unsigned-int-arithmetic.patch
	epatch "${FILESDIR}"/${PN}-2.47.2-tests-test-bounds-checked-int-arithmetic.patch

	# From GNOME:
	# 	https://git.gnome.org/browse/glib/commit/?id=1a2a689deacaac32b351ae97b00d8c35a6499cf6
	# 	https://git.gnome.org/browse/glib/commit/?id=15c5e643c64b5f428fdbb515625dd6e939dcd40b
	# 	https://git.gnome.org/browse/glib/commit/?id=b36b4941a634af096d21f906caae25ef35161166
	# 	https://git.gnome.org/browse/glib/commit/?id=0bfbb0d257593b2fcfaaf9bf09c586057ecfac25
	# 	https://git.gnome.org/browse/glib/commit/?id=9834f79279574e2cddc4dcb6149da9bd782dd40d
	# 	https://git.gnome.org/browse/glib/commit/?id=db2367e8782d7a39fc3e93d13f6a16f10cad04c2
	# 	https://git.gnome.org/browse/glib/commit/?id=ba12fbf8f8861e634def9fc0fb5e9ea603269803
	# 	https://git.gnome.org/browse/glib/commit/?id=f2fb877ef796c543f8ca166c7e05a434f163faf7
	epatch "${FILESDIR}"/${PN}-2.43.2-doc-glib-fix-all-undocumented-unused-undeclared-symbols.patch
	epatch "${FILESDIR}"/${PN}-2.45.1-gversionmacros-add-2-46-version-macros.patch
	epatch "${FILESDIR}"/${PN}-2.47.1-glib-add-2-48-availibity-macros.patch
	epatch "${FILESDIR}"/${PN}-2.47.2-gtrashstack-uninline-and-deprecate.patch
	epatch "${FILESDIR}"/${PN}-2.47.2-gutils-clean-up-bit-funcs-inlining-mess.patch
	epatch "${FILESDIR}"/${PN}-2.47.2-glib-clean-up-the-inline-mess-once-and-for-all.patch
	epatch "${FILESDIR}"/${PN}-2.47.3-gutils-g-bit-inlines-add-visibility-macros.patch
	epatch "${FILESDIR}"/${PN}-2.47.4-glibconfig-h-win32-in-remove-g-can-inline.patch

	# From GNOME:
	# 	https://git.gnome.org/browse/glib/commit/?id=ec6971b864a3faffadd0bf4a87c7c1b47697fc83
	epatch "${FILESDIR}"/${PN}-2.47.4-gtypes-h-move-g-static-assert-to-function-scope.patch

	# From GNOME:
	# 	https://git.gnome.org/browse/glib/commit/?id=aead1c046dd39748cca449b55ec300ba5f025365
	epatch "${FILESDIR}"/${PN}-2.47.92-gvariant-text-fix-scan-of-positional-parameters.patch

	# From GNOME:
	# 	https://git.gnome.org/browse/glib/commit/?id=f9d9f9c056d96eccbb75dcbdef2b58f6d2a3edea
	# 	https://git.gnome.org/browse/glib/commit/?id=3624e70508d414ae734c0b51f81839f8b5b1c809
	# 	https://git.gnome.org/browse/glib/commit/?id=61136c2c7333a937adb20a4a43f32e66bf89c2f5
	# 	https://git.gnome.org/browse/glib/commit/?id=c7f46997351805e436803ac74a49a88aa1602579
	# 	https://git.gnome.org/browse/glib/commit/?id=ba18667bb467ef4734f5d8a9bbeabcad39be4ecc
	# 	https://git.gnome.org/browse/glib/commit/?id=1ff79690fbd57a1029918ff37b7890b1096854b6
	# 	https://git.gnome.org/browse/glib/commit/?id=0d1eecddd4a87f4fcf6273e0ca95f11019582778
	# 	https://git.gnome.org/browse/glib/commit/?id=4e1567a079c13036320802f49ee8f78f78d0273a
	# 	https://git.gnome.org/browse/glib/commit/?id=8e23a514b02c67104f03545dec58116f00087229
	epatch "${FILESDIR}"/${PN}-2.47.1-update-to-unicode-8-0.patch
	epatch "${FILESDIR}"/${PN}-2.47.1-update-unicode-test-data-for-unicode-8.patch
	epatch "${FILESDIR}"/${PN}-2.47.4-trivial-doc-comment-fix.patch
	epatch "${FILESDIR}"/${PN}-2.50.1-unicode-update-break-mappings.patch
	epatch "${FILESDIR}"/${PN}-2.50.1-unicode-update-to-unicode-9-0-0.patch
	epatch "${FILESDIR}"/${PN}-2.50.1-unicode-update-test-data-files-for-unicode-9-0-0.patch
	epatch "${FILESDIR}"/${PN}-2.50.1-unicode-fix-ordering-in-iso15924-tags-to-match-gunicodescript-enum.patch
	epatch "${FILESDIR}"/${PN}-2.53.4-unicode-update-to-unicode-10-0-0.patch
	epatch "${FILESDIR}"/${PN}-2.53.4-unicode-update-test-data-files-for-unicode-10-0-0.patch

	# gdbus-codegen is a separate package
	epatch "${FILESDIR}"/${PN}-2.40.0-external-gdbus-codegen.patch

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

	epatch_user

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
	python_export_best

	# Related test is a bit nitpicking
	mkdir "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"
	chmod 0700 "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"

	# Hardened: gdb needs this, bug #338891
	if host-is-pax ; then
		pax-mark -mr "${BUILD_DIR}"/tests/.libs/assert-msg-test \
			|| die "Hardened adjustment failed"
	fi

	# Need X for dbus-launch session X11 initialization
	Xemake check
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_install_all() {
	DOCS="AUTHORS ChangeLog* NEWS* README"
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
