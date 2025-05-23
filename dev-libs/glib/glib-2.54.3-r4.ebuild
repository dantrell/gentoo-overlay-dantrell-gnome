# Distributed under the terms of the GNU General Public License v2

# Until bug #537330 glib is a reverse dependency of pkgconfig and, then
# adding new dependencies end up making stage3 to grow. Every addition needs
# then to be think very closely.

EAPI="6"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
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
SLOT="2/54"
KEYWORDS="*"

IUSE="dbus debug +elf fam kernel_linux +mime selinux static-libs systemtap test utils xattr"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	test? ( ${PYTHON_REQUIRED_USE} )
"

RESTRICT="!test? ( test )"

# Added util-linux multilib dependency to have libmount support (which
# is always turned on on linux systems, unless explicitly disabled, but
# this ebuild does not do that anyway) (bug #599586)
# * elfutils (via libelf) does not build on Windows. gresources are not embedded
# within ELF binaries on that platform anyway and inspecting ELF binaries from
# other platforms is not that useful so exclude the dependency in this case.
RDEPEND="
	!<dev-util/gdbus-codegen-${PV}
	>=dev-libs/libpcre-8.13:3[${MULTILIB_USEDEP},static-libs?]
	>=virtual/libiconv-0-r1[${MULTILIB_USEDEP}]
	>=dev-libs/libffi-3.0.13-r1:=[${MULTILIB_USEDEP}]
	>=virtual/libintl-0-r2[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}]
	kernel_linux? ( sys-apps/util-linux[${MULTILIB_USEDEP}] )
	selinux? ( >=sys-libs/libselinux-2.2.2-r5[${MULTILIB_USEDEP}] )
	xattr? ( >=sys-apps/attr-2.4.47-r1[${MULTILIB_USEDEP}] )
	fam? ( >=virtual/fam-0-r1[${MULTILIB_USEDEP}] )
	${PYTHON_DEPS}
	elf? ( virtual/libelf:0= )
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.1.2
	>=dev-libs/libxslt-1.0
	>=sys-devel/gettext-0.11
	>=dev-build/gtk-doc-am-1.20
	systemtap? ( >=dev-debug/systemtap-1.3 )
	test? (
		dev-debug/gdb
		${PYTHON_DEPS}
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

MULTILIB_CHOST_TOOLS=(
	/usr/bin/gio-querymodules$(get_exeext)
)

pkg_setup() {
	if use kernel_linux ; then
		CONFIG_CHECK="~INOTIFY_USER"
		if use test ; then
			CONFIG_CHECK="~IPV6"
			WARNING_IPV6="Your kernel needs IPV6 support for running some tests, skipping them."
		fi
		linux-info_pkg_setup
	fi
	python_setup
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
			sed -i -e "/g_test_add_func/d" gio/tests/desktop-app-info.c || die
		fi

		# gdesktopappinfo requires existing terminal (gnome-terminal or any
		# other), falling back to xterm if one doesn't exist
		if ! has_version x11-terms/xterm && ! has_version x11-terms/gnome-terminal ; then
			ewarn "Some tests will be skipped due to missing terminal program"
			sed -i -e "/appinfo\/launch/d" gio/tests/appinfo.c || die
		fi

		# https://bugzilla.gnome.org/show_bug.cgi?id=722604
		sed -i -e "/timer\/stop/d" glib/tests/timer.c || die
		sed -i -e "/timer\/basic/d" glib/tests/timer.c || die

		ewarn "Tests for search-utils have been skipped"
		sed -i -e "/search-utils/d" glib/tests/Makefile.am || die
	else
		# Don't build tests, also prevents extra deps, bug #512022
		sed -i -e 's/ tests//' {.,gio,glib}/Makefile.am || die
	fi

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/-/commit/8e8f4e6486c1578ae15d63835acd06f237324a6d
	# 	https://gitlab.gnome.org/GNOME/glib/-/commit/c79c234c352ff748056a30da6d4a49de0d2f878d
	# 	https://gitlab.gnome.org/GNOME/glib/-/commit/359b27d441a4dd701260d041e633e7241c314627
	eapply "${FILESDIR}"/${PN}-2.55.0-docs-fix-various-minor-syntax-errors-in-gtk-doc-comments.patch
	eapply "${FILESDIR}"/${PN}-2.57.2-unicode-update-to-unicode-11-0-0.patch
	eapply "${FILESDIR}"/${PN}-2.57.2-unicode-update-test-data-files-for-unicode-11-0-0.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/-/merge_requests/411
	# 	https://www.openwall.com/lists/oss-security/2018/10/23/5
	eapply "${FILESDIR}"/${PN}-2.52.3-various-gvariant-gmarkup-and-gdbus-fuzzing-fixes.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/glib/-/commit/d8f8f4d637ce43f8699ba94c9b7648beda0ca174 (CVE-2019-12450)
	eapply "${FILESDIR}"/${PN}-2.61.1-gfile-limit-access-to-files-when-copying.patch

	# Leave python shebang alone - handled by python_replicate_script
	# We could call python_setup and give configure a valid --with-python
	# arg, but that would mean a build dep on python when USE=utils.
	sed -e 's:@PYTHON@:python:' \
		-i gobject/glib-{genmarshal.in,mkenums.in} || die
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

	# libelf used only by the gresource bin
	ECONF_SOURCE="${S}" gnome2_src_configure ${myconf} \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable xattr) \
		$(use_enable fam) \
		$(use_enable kernel_linux libmount) \
		$(use_enable selinux) \
		$(use_enable static-libs static) \
		$(use_enable systemtap dtrace) \
		$(use_enable systemtap systemtap) \
		$(multilib_native_use_enable utils libelf) \
		--disable-compile-warnings \
		--enable-man \
		--with-pcre=system \
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
	gnome2_src_install completiondir="$(get_bashcompdir)"
	keepdir /usr/$(get_libdir)/gio/modules
}

multilib_src_install_all() {
	einstalldocs

	python_fix_shebang "${ED}"/usr/bin/glib-mkenums
	python_fix_shebang "${ED}"/usr/bin/glib-genmarshal
	python_fix_shebang "${ED}"/usr/bin/gtester-report

	# Do not install charset.alias even if generated, leave it to libiconv
	rm -f "${ED}/usr/lib/charset.alias"

	# Don't install gdb python macros, bug 291328
	rm -rf "${ED}/usr/share/gdb/" "${ED}/usr/share/glib-2.0/gdb/"
}

pkg_preinst() {
	gnome2_pkg_preinst

	# Make gschemas.compiled belong to glib alone
	local cache="usr/share/glib-2.0/schemas/gschemas.compiled"

	if [[ -e ${EROOT}${cache} ]]; then
		cp "${EROOT}"${cache} "${ED}"/${cache} || die
	else
		touch "${ED}"/${cache} || die
	fi

	multilib_pkg_preinst() {
		# Make giomodule.cache belong to glib alone
		local cache="usr/$(get_libdir)/gio/giomodule.cache"

		if [[ -e ${EROOT}${cache} ]]; then
			cp "${EROOT}"${cache} "${ED}"/${cache} || die
		else
			touch "${ED}"/${cache} || die
		fi
	}

	multilib_foreach_abi multilib_pkg_preinst
}

pkg_postinst() {
	# force (re)generation of gschemas.compiled
	GNOME2_ECLASS_GLIB_SCHEMAS="force"

	gnome2_pkg_postinst

	multilib_pkg_postinst() {
		gnome2_giomodule_cache_update \
			|| die "Update GIO modules cache failed (for ${ABI})"
	}
	multilib_foreach_abi multilib_pkg_postinst
}

pkg_postrm() {
	gnome2_pkg_postrm

	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		multilib_pkg_postrm() {
			rm -f "${EROOT}"usr/$(get_libdir)/gio/giomodule.cache
		}
		multilib_foreach_abi multilib_pkg_postrm
		rm -f "${EROOT}"usr/share/glib-2.0/schemas/gschemas.compiled
	fi
}
