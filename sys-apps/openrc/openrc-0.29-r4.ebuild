# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic pam toolchain-funcs usr-ldscript

DESCRIPTION="OpenRC manages the services, startup and shutdown of a host"
HOMEPAGE="https://github.com/openrc/openrc/"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"

IUSE="audit debug ncurses pam newnet prefix +netifrc selinux static-libs unicode +vanilla-loopback +vanilla-warnings"

COMMON_DEPEND="
	ncurses? ( sys-libs/ncurses:0= )
	pam? (
		sys-auth/pambase
		sys-libs/pam
	)
	audit? ( sys-process/audit )
	sys-process/psmisc
	!<sys-process/procps-3.3.9-r2
	selinux? (
		sys-apps/policycoreutils
		>=sys-libs/libselinux-2.6
	)
	!<sys-apps/baselayout-2.1-r1
	!<sys-fs/udev-init-scripts-27"
DEPEND="${COMMON_DEPEND}
	virtual/os-headers
	ncurses? ( virtual/pkgconfig )"
RDEPEND="${COMMON_DEPEND}
	!prefix? (
		>=sys-apps/sysvinit-2.86-r6[selinux?]
		virtual/tmpfiles
	)
	selinux? (
		>=sec-policy/selinux-base-policy-2.20170204-r4
		>=sec-policy/selinux-openrc-2.20170204-r4
	)
"

PDEPEND="netifrc? ( net-misc/netifrc )"

src_prepare() {
	default

	sed -i 's:0444:0644:' mk/sys.mk || die

	# From OpenRC:
	# 	https://github.com/OpenRC/openrc/commit/b1c3422f453921e838d419640fe39144dbf8d13d
	# 	https://github.com/OpenRC/openrc/commit/db4a578273dbfa15b8b96686391bcc9ecc04b646
	# 	https://github.com/OpenRC/openrc/commit/a7c99506d9de81b9a2a7547bd11715073de1ce95
	# 	https://github.com/OpenRC/openrc/commit/cee3919908c2d715fd75a796873e3308209a4c2e
	# 	https://github.com/OpenRC/openrc/commit/7cb8d943236fe651ac54c64f8167f7c4369f649c
	eapply "${FILESDIR}"/${PN}-0.31.2-selinux-use-openrc-contexts-path-to-get-contexts.patch
	eapply "${FILESDIR}"/${PN}-0.31.2-selinux-fix-const-qualifier-warning.patch
	eapply "${FILESDIR}"/${PN}-0.35-fix-repeated-dependency-cache-rebuild-if-clock-skewed.patch
	eapply "${FILESDIR}"/${PN}-0.35-clean-up-the-calls-to-group-add-service.patch
	eapply "${FILESDIR}"/${PN}-0.39.1-stop-mounting-efivarfs-read-only.patch

	# From OpenRC:
	# 	https://github.com/OpenRC/openrc/commit/918d955fd2de1f594b83508f5ddd5271534e3591
	# 	https://github.com/OpenRC/openrc/commit/4af5a80b0c516773286cc30e743dc90a2d19df23
	# 	https://github.com/OpenRC/openrc/commit/87c98ebb01873120eecc1757e615b3a4c14a2f1f
	# 	https://github.com/OpenRC/openrc/commit/1771bc2a83fe65bfe6ec3e93ea7632609e697a38
	# 	https://github.com/OpenRC/openrc/commit/5dd1d39d20c118064d31ed65dc7ae2de75dd7908
	# 	https://github.com/OpenRC/openrc/commit/7ddc281ab6fd11b63f41059818b0de4748e2821f
	# 	https://github.com/OpenRC/openrc/commit/375ef42393f3dc6edbaa2cb70c79b2366072db38
	eapply "${FILESDIR}"/${PN}-0.35-checkpath-use-lchown-instead-of-chown.patch
	eapply "${FILESDIR}"/${PN}-0.35-rc-deptree-load-return-null-if-the-stat-call-is-not-successful.patch
	eapply "${FILESDIR}"/${PN}-0.35-checkpath-fix-lchown-error-message.patch
	eapply "${FILESDIR}"/${PN}-0.35-checkpath-use-fchown-and-fchmod-to-handle-ownership-and-mode-changes.patch
	eapply "${FILESDIR}"/${PN}-0.35-typo-fix.patch
	eapply "${FILESDIR}"/${PN}-0.42-fix-build-with-clang.patch
	eapply "${FILESDIR}"/${PN}-9999-src-rc-rc-logger-h-fix-build-failure-against-gcc-10.patch

	if ! use vanilla-warnings; then
		# We shouldn't have to deal with deprecation warnings for runscript
		eapply "${FILESDIR}"/${PN}-0.21-disable-deprecation-warnings-for-runscript.patch
	fi

	if ! use vanilla-loopback; then
		# We shouldn't have to wait for a valid network connection before continuing with startup
		eapply "${FILESDIR}"/${PN}-0.25-make-lookback-provide-net.patch
	fi
}

src_compile() {
	unset LIBDIR #266688

	MAKE_ARGS="${MAKE_ARGS}
		LIBNAME=$(get_libdir)
		LIBEXECDIR=${EPREFIX}/lib/rc
		MKNET=$(usex newnet)
		MKSELINUX=$(usex selinux)
		MKAUDIT=$(usex audit)
		MKPAM=$(usev pam)
		MKSTATICLIBS=$(usex static-libs)"

	local brand="Unknown"
	MAKE_ARGS="${MAKE_ARGS} OS=Linux"
	brand="Linux"
	export BRANDING="Gentoo ${brand}"
	use prefix && MAKE_ARGS="${MAKE_ARGS} MKPREFIX=yes PREFIX=${EPREFIX}"
	export DEBUG=$(usev debug)
	export MKTERMCAP=$(usev ncurses)

	tc-export CC AR RANLIB
	emake ${MAKE_ARGS}
}

# set_config <file> <option name> <yes value> <no value> test
# a value of "#" will just comment out the option
set_config() {
	local file="${ED}/$1" var=$2 val com
	eval "${@:5}" && val=$3 || val=$4
	[[ ${val} == "#" ]] && com="#" && val='\2'
	sed -i -r -e "/^#?${var}=/{s:=([\"'])?([^ ]*)\1?:=\1${val}\1:;s:^#?:${com}:}" "${file}"
}

set_config_yes_no() {
	set_config "$1" "$2" YES NO "${@:3}"
}

src_install() {
	emake ${MAKE_ARGS} DESTDIR="${D}" install

	# move the shared libs back to /usr so ldscript can install
	# more of a minimal set of files
	# disabled for now due to #270646
	#mv "${ED}"/$(get_libdir)/lib{einfo,rc}* "${ED}"/usr/$(get_libdir)/ || die
	#gen_usr_ldscript -a einfo rc
	gen_usr_ldscript libeinfo.so
	gen_usr_ldscript librc.so

	keepdir /lib/rc/tmp

	# Backup our default runlevels
	dodir /usr/share/"${PN}"
	cp -PR "${ED}"/etc/runlevels "${ED}"/usr/share/${PN} || die

	# Setup unicode defaults for silly unicode users
	set_config_yes_no /etc/rc.conf unicode use unicode

	# Cater to the norm
	set_config_yes_no /etc/conf.d/keymaps windowkeys '(' use x86 '||' use amd64 ')'

	# On HPPA, do not run consolefont by default (bug #222889)
	if use hppa; then
		rm -f "${ED}"/etc/runlevels/boot/consolefont
	fi

	# Support for logfile rotation
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/openrc.logrotate openrc

	# install gentoo pam.d files
	newpamd "${FILESDIR}"/start-stop-daemon.pam start-stop-daemon
	newpamd "${FILESDIR}"/start-stop-daemon.pam supervise-daemon

	# install documentation
	dodoc ChangeLog *.md
	if use newnet; then
		dodoc README.newnet
	fi
}

pkg_preinst() {
	# avoid default thrashing in conf.d files when possible #295406
	if [[ -e "${EROOT}"/etc/conf.d/hostname ]] ; then
		(
		unset hostname HOSTNAME
		source "${EROOT}"/etc/conf.d/hostname
		: ${hostname:=${HOSTNAME}}
		[[ -n ${hostname} ]] && set_config /etc/conf.d/hostname hostname "${hostname}"
		)
	fi

	# set default interactive shell to sulogin if it exists
	set_config /etc/rc.conf rc_shell /sbin/sulogin "#" test -e /sbin/sulogin
	return 0
}

pkg_postinst() {
	if use hppa; then
		elog "Setting the console font does not work on all HPPA consoles."
		elog "You can still enable it by running:"
		elog "# rc-update add consolefont boot"
	fi

	if ! use newnet && ! use netifrc; then
		ewarn "You have emerged OpenRc without network support. This"
		ewarn "means you need to SET UP a network manager such as"
		ewarn "	net-misc/netifrc, net-misc/dhcpcd, net-misc/wicd,"
		ewarn "net-misc/NetworkManager, or net-vpn/badvpn."
		ewarn "Or, you have the option of emerging openrc with the newnet"
		ewarn "use flag and configuring /etc/conf.d/network and"
		ewarn "/etc/conf.d/staticroute if you only use static interfaces."
		ewarn
	fi

	if use newnet && [ ! -e "${EROOT}"/etc/runlevels/boot/network ]; then
		ewarn "Please add the network service to your boot runlevel"
		ewarn "as soon as possible. Not doing so could leave you with a system"
		ewarn "without networking."
		ewarn
	fi

	if ! use vanilla-loopback; then
		ewarn "In this version of OpenRC, the loopback interface"
		ewarn "satisfies the net virtual."
		ewarn
	fi
}
