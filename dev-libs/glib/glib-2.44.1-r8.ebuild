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
SLOT="2/44"
KEYWORDS="*"

IUSE="dbus fam kernel_linux +mime selinux static-libs systemtap test utils xattr"
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
	# 	https://gitlab.gnome.org/GNOME/glib/commit/d0219f25970c740ac1a8965754868d54bcd90eeb
	# 	https://gitlab.gnome.org/GNOME/glib/commit/7dd9ffbcfff3561d2d1bcd247c052e4c4399623f
	epatch "${FILESDIR}"/${PN}-2.47.2-glib-add-bounds-checked-unsigned-int-arithmetic.patch
	epatch "${FILESDIR}"/${PN}-2.47.2-tests-test-bounds-checked-int-arithmetic.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/15c5e643c64b5f428fdbb515625dd6e939dcd40b
	# 	https://gitlab.gnome.org/GNOME/glib/commit/b36b4941a634af096d21f906caae25ef35161166
	# 	https://gitlab.gnome.org/GNOME/glib/commit/0bfbb0d257593b2fcfaaf9bf09c586057ecfac25
	# 	https://gitlab.gnome.org/GNOME/glib/commit/9834f79279574e2cddc4dcb6149da9bd782dd40d
	# 	https://gitlab.gnome.org/GNOME/glib/commit/db2367e8782d7a39fc3e93d13f6a16f10cad04c2
	# 	https://gitlab.gnome.org/GNOME/glib/commit/ba12fbf8f8861e634def9fc0fb5e9ea603269803
	# 	https://gitlab.gnome.org/GNOME/glib/commit/f2fb877ef796c543f8ca166c7e05a434f163faf7
	epatch "${FILESDIR}"/${PN}-2.45.1-gversionmacros-add-2-46-version-macros.patch
	epatch "${FILESDIR}"/${PN}-2.47.1-glib-add-2-48-availibity-macros.patch
	epatch "${FILESDIR}"/${PN}-2.47.2-gtrashstack-uninline-and-deprecate.patch
	epatch "${FILESDIR}"/${PN}-2.47.2-gutils-clean-up-bit-funcs-inlining-mess.patch
	epatch "${FILESDIR}"/${PN}-2.47.2-glib-clean-up-the-inline-mess-once-and-for-all.patch
	epatch "${FILESDIR}"/${PN}-2.47.3-gutils-g-bit-inlines-add-visibility-macros.patch
	epatch "${FILESDIR}"/${PN}-2.47.4-glibconfig-h-win32-in-remove-g-can-inline.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/ec6971b864a3faffadd0bf4a87c7c1b47697fc83
	epatch "${FILESDIR}"/${PN}-2.47.4-gtypes-h-move-g-static-assert-to-function-scope.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/aead1c046dd39748cca449b55ec300ba5f025365
	epatch "${FILESDIR}"/${PN}-2.47.92-gvariant-text-fix-scan-of-positional-parameters.patch

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
	epatch "${FILESDIR}"/${PN}-2.47.1-update-to-unicode-8-0.patch
	epatch "${FILESDIR}"/${PN}-2.47.1-update-unicode-test-data-for-unicode-8.patch
	epatch "${FILESDIR}"/${PN}-2.47.4-trivial-doc-comment-fix.patch
	epatch "${FILESDIR}"/${PN}-2.50.1-unicode-update-break-mappings.patch
	epatch "${FILESDIR}"/${PN}-2.50.1-unicode-update-to-unicode-9-0-0.patch
	epatch "${FILESDIR}"/${PN}-2.50.1-unicode-update-test-data-files-for-unicode-9-0-0.patch
	epatch "${FILESDIR}"/${PN}-2.50.1-unicode-fix-ordering-in-iso15924-tags-to-match-gunicodescript-enum.patch
	epatch "${FILESDIR}"/${PN}-2.53.4-unicode-update-to-unicode-10-0-0.patch
	epatch "${FILESDIR}"/${PN}-2.53.4-unicode-update-test-data-files-for-unicode-10-0-0.patch
	epatch "${FILESDIR}"/${PN}-2.55.0-docs-fix-various-minor-syntax-errors-in-gtk-doc-comments.patch
	epatch "${FILESDIR}"/${PN}-2.57.2-unicode-update-to-unicode-11-0-0.patch
	epatch "${FILESDIR}"/${PN}-2.57.2-unicode-update-test-data-files-for-unicode-11-0-0.patch


	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/merge_requests/411
	# 	https://www.openwall.com/lists/oss-security/2018/10/23/5
	epatch "${FILESDIR}"/${PN}-2.42.2-various-gvariant-gmarkup-and-gdbus-fuzzing-fixes.patch

	# gio/gthreadedresolver.c has outdated copy of bionic headers (for android)
	epatch "${FILESDIR}"/${PN}-2.44.1-bionic-nameser.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/commit/d8f8f4d637ce43f8699ba94c9b7648beda0ca174 (CVE-2019-12450)
	epatch "${FILESDIR}"/${PN}-2.61.1-gfile-limit-access-to-files-when-copying.patch

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

	# These configure tests don't work when cross-compiling.
	if tc-is-cross-compiler ; then
		# https://bugzilla.gnome.org/show_bug.cgi?id=756473
		case ${CHOST} in
		hppa*|metag*) export glib_cv_stack_grows=yes ;;
		*)            export glib_cv_stack_grows=no ;;
		esac
		# https://bugzilla.gnome.org/show_bug.cgi?id=756474
		export glib_cv_uscore=no
		# https://bugzilla.gnome.org/show_bug.cgi?id=756475
		export ac_cv_func_posix_get{pwuid,grgid}_r=yes
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
