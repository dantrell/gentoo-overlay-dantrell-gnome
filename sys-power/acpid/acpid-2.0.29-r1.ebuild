# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit linux-info systemd

DESCRIPTION="Daemon for Advanced Configuration and Power Interface"
HOMEPAGE="https://sourceforge.net/projects/acpid2"
SRC_URI="mirror://sourceforge/${PN}2/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="selinux systemd"

RDEPEND="selinux? ( sec-policy/selinux-apm )"
DEPEND=">=sys-kernel/linux-headers-3
	systemd? ( sys-apps/systemd )
"

pkg_pretend() {
	local CONFIG_CHECK="~INPUT_EVDEV"
	local WARNING_INPUT_EVDEV="CONFIG_INPUT_EVDEV is required for ACPI button event support."
	[[ ${MERGE_TYPE} != buildonly ]] && check_extra_config
}

PATCHES=(
	# From Funtoo:
	# 	https://bugs.funtoo.org/browse/FL-1329
	# 	https://bugs.funtoo.org/browse/FL-1439
	"${FILESDIR}"/patches/sort-pms.patch
	"${FILESDIR}"/patches/rename-gnome-pms.patch
	"${FILESDIR}"/patches/add-cinnamon-pms.patch

	# From Gentoo:
	# 	https://bugs.gentoo.org/515088
	# 	https://bugs.gentoo.org/538590
	# 	https://bugs.gentoo.org/628698
	"${FILESDIR}"/patches/fix-kde4-pms.patch
	"${FILESDIR}"/patches/add-mate-pms.patch
	"${FILESDIR}"/patches/add-kde5-pms.patch
)

src_install() {
	emake DESTDIR="${D}" install

	newdoc kacpimon/README README.kacpimon
	dodoc -r samples
	rm -f "${D}"/usr/share/doc/${PF}/COPYING || die

	exeinto /etc/acpi
	newexe "${FILESDIR}"/${PN}-1.0.6-default.sh default.sh
	exeinto /etc/acpi/actions
	newexe samples/powerbtn/powerbtn.sh powerbtn.sh
	insinto /etc/acpi/events
	newins "${FILESDIR}"/${PN}-1.0.4-default default

	newinitd "${FILESDIR}"/${PN}-2.0.26-init.d ${PN}
	newconfd "${FILESDIR}"/${PN}-2.0.16-conf.d ${PN}

	if use systemd ; then
		systemd_dounit "${FILESDIR}"/systemd/${PN}.{service,socket}
	fi
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog
		elog "You may wish to read the Gentoo Linux Power Management Guide,"
		elog "which can be found online at:"
		elog "https://wiki.gentoo.org/wiki/Power_management/Guide"
		elog
	fi

	# files/systemd/acpid.socket -> ListenStream=/run/acpid.socket
	mkdir -p "${ROOT%/}"/run

	if ! grep -qs "^tmpfs.*/run " "${ROOT%/}"/proc/mounts ; then
		echo
		ewarn "You should reboot the system now to get /run mounted with tmpfs!"
	fi
}
