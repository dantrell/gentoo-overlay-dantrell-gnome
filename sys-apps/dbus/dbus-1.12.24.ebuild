# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
TMPFILES_OPTIONAL=1

inherit autotools flag-o-matic linux-info python-any-r1 readme.gentoo-r1 systemd tmpfiles virtualx multilib-minimal

DESCRIPTION="A message bus system, a simple way for applications to talk to each other"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/dbus/"
SRC_URI="https://dbus.freedesktop.org/releases/dbus/${P}.tar.gz"

LICENSE="|| ( AFL-2.1 GPL-2 )"
SLOT="0"
KEYWORDS="*"

IUSE="debug doc elogind selinux static-libs systemd test user-session X"
REQUIRED_USE="?? ( elogind systemd )"

RESTRICT="!test? ( test )"

BDEPEND="
	acct-user/messagebus
	app-text/xmlto
	app-text/docbook-xml-dtd:4.4
	dev-build/autoconf-archive
	virtual/pkgconfig
	doc? ( app-text/doxygen )
"
COMMON_DEPEND="
	>=dev-libs/expat-2.1.0
	elogind? ( sys-auth/elogind )
	selinux? ( sys-libs/libselinux )
	systemd? ( sys-apps/systemd:0= )
	X? (
		x11-libs/libX11
		x11-libs/libXt
	)
"
DEPEND="${COMMON_DEPEND}
	dev-libs/expat
	test? (
		${PYTHON_DEPS}
		>=dev-libs/glib-2.40:2
	)
"
RDEPEND="${COMMON_DEPEND}
	acct-user/messagebus
	selinux? ( sec-policy/selinux-dbus )
	systemd? ( virtual/tmpfiles )
"

DOC_CONTENTS="
	Some applications require a session bus in addition to the system
	bus. Please see \`man dbus-launch\` for more information.
"

# out of sources build dir for make check
TBD="${WORKDIR}/${P}-tests-build"

PATCHES=(
	"${FILESDIR}"/${PN}-enable-elogind.patch
	"${FILESDIR}"/${PN}-daemon-optional.patch # bug #653136

	"${FILESDIR}"/${PN}-1.12.22-check-fd.patch

	# https://bugs.gentoo.org/836560
	"${FILESDIR}"/${PN}-1.14.0-oom_score_adj.patch
)

pkg_setup() {
	use test && python-any-r1_pkg_setup

	if use kernel_linux; then
		CONFIG_CHECK="~EPOLL"
		linux-info_pkg_setup
	fi
}

src_prepare() {
	# Tests were restricted because of this
	sed -i \
		-e 's/.*bus_dispatch_test.*/printf ("Disabled due to excess noise\\n");/' \
		-e '/"dispatch"/d' \
		bus/test-main.c || die

	default

	if [[ ${CHOST} == *-solaris* ]]; then
		# fix standards conflict, due to gcc being c99 by default nowadays
		sed -i \
			-e 's/_XOPEN_SOURCE=500/_XOPEN_SOURCE=600/' \
			configure.ac || die
	fi

	# required for bug #263909, cross-compile so don't remove eautoreconf
	eautoreconf
}

src_configure() {
	local rundir=$(usex kernel_linux /run /var/run)

	sed -e "s;@rundir@;${EPREFIX}${rundir};g" "${FILESDIR}"/dbus.initd.in \
		> "${T}"/dbus.initd || die

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local docconf myconf testconf

	# so we can get backtraces from apps
	case ${CHOST} in
		*-mingw*)
			# error: unrecognized command line option '-rdynamic', bug #488036
			;;
		*)
			append-flags -rdynamic
			;;
	esac

	# libaudit is *only* used in DBus wrt SELinux support, so disable it, if
	# not on an SELinux profile.
	myconf=(
		--localstatedir="${EPREFIX}/var"
		$(use_enable static-libs static)
		$(use_enable debug verbose-mode)
		--disable-asserts
		--disable-checks
		$(use_enable selinux)
		$(use_enable selinux libaudit)
		--disable-apparmor
		$(use_enable kernel_linux inotify)
		--disable-kqueue
		$(use_enable elogind)
		$(use_enable systemd)
		$(use_enable user-session)
		--disable-embedded-tests
		--disable-modular-tests
		$(use_enable debug stats)
		--with-session-socket-dir="${EPREFIX}"/tmp
		--with-system-pid-file="${EPREFIX}${rundir}"/dbus.pid
		--with-system-socket="${EPREFIX}${rundir}"/dbus/system_bus_socket
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
		--with-systemduserunitdir="$(systemd_get_userunitdir)"
		--with-dbus-user=messagebus
		$(use_with X x)
	)

	if [[ ${CHOST} == *-darwin* ]]; then
		myconf+=(
			--enable-launchd
			--with-launchd-agent-dir="${EPREFIX}"/Library/LaunchAgents
		)
	fi

	if multilib_is_native_abi; then
		docconf=(
			--enable-xml-docs
			$(use_enable doc doxygen-docs)
		)
	else
		docconf=(
			--disable-xml-docs
			--disable-doxygen-docs
		)
		myconf+=(
			--disable-daemon
			--disable-selinux
			--disable-libaudit
			--disable-elogind
			--disable-systemd
			--without-x
		)
	fi

	einfo "Running configure in ${BUILD_DIR}"
	ECONF_SOURCE="${S}" econf "${myconf[@]}" "${docconf[@]}"

	if multilib_is_native_abi && use test; then
		mkdir "${TBD}" || die
		cd "${TBD}" || die
		testconf=(
			$(use_enable test asserts)
			$(use_enable test checks)
			$(use_enable test embedded-tests)
			$(use_enable test stats)
			$(has_version dev-libs/dbus-glib && echo --enable-modular-tests)
		)
		einfo "Running configure in ${TBD}"
		ECONF_SOURCE="${S}" econf "${myconf[@]}" "${testconf[@]}"
	fi
}

multilib_src_compile() {
	if multilib_is_native_abi; then
		# After the compile, it uses a selinuxfs interface to
		# check if the SELinux policy has the right support
		use selinux && addwrite /selinux/access

		einfo "Running make in ${BUILD_DIR}"
		emake

		if use test; then
			einfo "Running make in ${TBD}"
			emake -C "${TBD}"
		fi
	else
		emake -C dbus libdbus-1.la
	fi
}

src_test() {
	# DBUS_TEST_MALLOC_FAILURES=0 to avoid huge test logs
	# https://gitlab.freedesktop.org/dbus/dbus/-/blob/master/CONTRIBUTING.md#L231
	DBUS_TEST_MALLOC_FAILURES=0 DBUS_VERBOSE=1 virtx emake -j1 -C "${TBD}" check
}

multilib_src_install() {
	if multilib_is_native_abi; then
		emake DESTDIR="${D}" install
	else
		emake DESTDIR="${D}" install-pkgconfigDATA
		emake DESTDIR="${D}" -C dbus \
			install-libLTLIBRARIES install-dbusincludeHEADERS \
			install-nodist_dbusarchincludeHEADERS
	fi
}

multilib_src_install_all() {
	newinitd "${T}"/dbus.initd dbus

	if use X; then
		# dbus X session script (bug #77504)
		# turns out to only work for GDM (and startx). has been merged into
		# other desktop (kdm and such scripts)
		exeinto /etc/X11/xinit/xinitrc.d
		newexe "${FILESDIR}"/80-dbus-r1 80-dbus
	fi

	# Needs to exist for dbus sessions to launch
	keepdir /usr/share/dbus-1/services
	keepdir /etc/dbus-1/{session,system}.d
	# machine-id symlink from pkg_postinst()
	keepdir /var/lib/dbus
	# Let the init script create the /var/run/dbus directory
	rm -rf "${ED}"/var/run

	# sysusers.d configuration conflict (bug #761763)
	rm -rf "${ED}"/usr/lib/sysusers.d

	dodoc AUTHORS NEWS README doc/TODO
	readme.gentoo_create_doc

	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	readme.gentoo_print_elog

	if use systemd; then
		tmpfiles_process dbus.conf
	fi

	# Ensure unique id is generated and put it in /etc wrt bug #370451 but symlink
	# for DBUS_MACHINE_UUID_FILE (see tools/dbus-launch.c) and reverse
	# dependencies with hardcoded paths (although the known ones got fixed already)
	# TODO: should be safe to remove at least the ln because of the above tmpfiles_process?
	dbus-uuidgen --ensure="${EROOT}"/etc/machine-id
	ln -sf "${EPREFIX}"/etc/machine-id "${EROOT}"/var/lib/dbus/machine-id

	if [[ ${CHOST} == *-darwin* ]]; then
		local plist="org.freedesktop.dbus-session.plist"
		elog
		elog
		elog "For MacOS/Darwin we now ship launchd support for dbus."
		elog "This enables autolaunch of dbus at session login and makes"
		elog "dbus usable under MacOS/Darwin."
		elog
		elog "The launchd plist file ${plist} has been"
		elog "installed in ${EPREFIX}/Library/LaunchAgents."
		elog "For it to be used, you will have to do all of the following:"
		elog " + cd ~/Library/LaunchAgents"
		elog " + ln -s ${EPREFIX}/Library/LaunchAgents/${plist}"
		elog " + logout and log back in"
		elog
		elog "If your application needs a proper DBUS_SESSION_BUS_ADDRESS"
		elog "specified and refused to start otherwise, then export the"
		elog "the following to your environment:"
		elog " DBUS_SESSION_BUS_ADDRESS=\"launchd:env=DBUS_LAUNCHD_SESSION_BUS_SOCKET\""
	fi

	if use user-session; then
		ewarn "You have enabled user-session. Please note this can cause"
		ewarn "bogus behaviors in several dbus consumers that are not prepared"
		ewarn "for this dbus activation method yet."
		ewarn
		ewarn "See the following link for background on this change:"
		ewarn "https://lists.freedesktop.org/archives/systemd-devel/2015-January/027711.html"
		ewarn
		ewarn "Known issues are tracked here:"
		ewarn "https://bugs.gentoo.org/576028"
	fi
}
