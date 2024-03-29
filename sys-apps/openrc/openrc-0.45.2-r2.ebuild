# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit meson pam

DESCRIPTION="OpenRC manages the services, startup and shutdown of a host"
HOMEPAGE="https://github.com/openrc/openrc/"
SRC_URI="https://github.com/OpenRC/openrc/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~*"

IUSE="audit bash debug ncurses pam newnet +netifrc selinux sysv-utils unicode +vanilla-loopback vanilla-shutdown +vanilla-warnings"

COMMON_DEPEND="
	ncurses? ( sys-libs/ncurses:0= )
	pam? ( sys-libs/pam )
	audit? ( sys-process/audit )
	sys-process/psmisc
	selinux? (
		sys-apps/policycoreutils
		>=sys-libs/libselinux-2.6
	)"
DEPEND="${COMMON_DEPEND}
	virtual/os-headers
	ncurses? ( virtual/pkgconfig )"
RDEPEND="${COMMON_DEPEND}
	bash? ( app-shells/bash )
	!prefix? (
		sysv-utils? (
			!sys-apps/systemd[sysv-utils(-)]
			!sys-apps/sysvinit
		)
		!sysv-utils? (
			|| (
				>=sys-apps/sysvinit-2.86-r6[selinux?]
				sys-apps/s6-linux-init[sysv-utils(-)]
			)
		)
		virtual/tmpfiles
	)
	selinux? (
		>=sec-policy/selinux-base-policy-2.20170204-r4
		>=sec-policy/selinux-openrc-2.20170204-r4
	)
"

PDEPEND="netifrc? ( net-misc/netifrc )"

PATCHES=(
	"${FILESDIR}"/${PN}-0.45.2-grep-3.8.patch
)

src_prepare() {
	default

	if ! use vanilla-warnings; then
		# We shouldn't have to deal with deprecation warnings for runscript
		eapply "${FILESDIR}"/${PN}-0.45.2-disable-deprecation-warnings-for-runscript.patch
	fi

	if ! use vanilla-loopback; then
		# We shouldn't have to wait for a valid network connection before continuing with startup
		eapply "${FILESDIR}"/${PN}-0.25-make-lookback-provide-net.patch
	fi

	if ! use vanilla-shutdown; then
		# We shouldn't complicate the shutdown process
		eapply "${FILESDIR}"/${PN}-0.43.5-simplify-cgroup-cleanup.patch
	fi
}

src_configure() {
	local emesonargs=(
		$(meson_feature audit)
		"-Dbranding=\"Gentoo Linux\""
		$(meson_use newnet)
		-Dos=Linux
		$(meson_use pam)
		$(meson_feature selinux)
		-Drootprefix="${EPREFIX}"
		-Dshell=$(usex bash /bin/bash /bin/sh)
		$(meson_use sysv-utils sysvinit)
		-Dtermcap=$(usev ncurses)
	)
	# export DEBUG=$(usev debug)
	meson_src_configure
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
	meson_install

	keepdir /lib/rc/tmp

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

	if use pam; then
		# install gentoo pam.d files
		newpamd "${FILESDIR}"/start-stop-daemon.pam start-stop-daemon
		newpamd "${FILESDIR}"/start-stop-daemon.pam supervise-daemon
	fi

	# install documentation
	dodoc *.md
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
		ewarn "	net-misc/netifrc, net-misc/dhcpcd, net-misc/connman,"
		ewarn "	net-misc/NetworkManager, or net-vpn/badvpn."
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

	# added for 0.45 to handle seedrng/urandom switching (2022-06-07)
	for v in ${REPLACING_VERSIONS}; do
		[[ -x $(type rc-update) ]] || continue
		if ver_test $v -lt 0.45; then
			if rc-update show boot | grep -q urandom; then
				rc-update del urandom boot
				rc-update add seedrng boot
		fi
		fi
	done
}
