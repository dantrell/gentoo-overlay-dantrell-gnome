# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME_ORG_MODULE="NetworkManager"
GNOME2_EAUTORECONF="yes"
VALA_USE_DEPEND="vapigen"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit bash-completion-r1 gnome2 linux-info multilib python-any-r1 systemd readme.gentoo-r1 vala virtualx udev multilib-minimal

DESCRIPTION="A set of co-operative tools that make networking simple and straightforward"
HOMEPAGE="https://wiki.gnome.org/Projects/NetworkManager"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0" # add subslot if libnm-util.so.2 or libnm-glib.so.4 bumps soname version
KEYWORDS="*"

IUSE="audit bluetooth ck connection-sharing consolekit +dhclient dhcpcd elogind gnutls gtk-doc +introspection iwd json kernel_linux +nss +modemmanager ncurses ofono ovs policykit +ppp resolvconf selinux systemd teamd test vala +vanilla +wext +wifi"
REQUIRED_USE="
	bluetooth? ( modemmanager )
	gtk-doc? ( introspection )
	iwd? ( wifi )
	vala? ( introspection )
	vanilla? ( !dhcpcd )
	wext? ( wifi )
	|| ( nss gnutls )
	^^ ( dhclient dhcpcd )
	?? ( ck consolekit elogind systemd )
"

RESTRICT="!test? ( test )"

# gobject-introspection-0.10.3 is needed due to gnome bug 642300
# wpa_supplicant-0.7.3-r3 is needed due to bug 359271
COMMON_DEPEND="
	>=sys-apps/dbus-1.2[${MULTILIB_USEDEP}]
	>=dev-libs/dbus-glib-0.100[${MULTILIB_USEDEP}]
	dev-libs/glib:2=[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.40:2[${MULTILIB_USEDEP}]
	policykit? ( >=sys-auth/polkit-0.106 )
	net-libs/libndp[${MULTILIB_USEDEP}]
	>=net-misc/curl-7.24
	net-misc/iputils
	sys-apps/util-linux[${MULTILIB_USEDEP}]
	sys-libs/readline:0=
	>=virtual/libudev-175:=[${MULTILIB_USEDEP}]
	audit? ( sys-process/audit )
	bluetooth? ( >=net-wireless/bluez-5 )
	ck? ( >=sys-power/upower-0.99:=[ck] )
	connection-sharing? (
		net-dns/dnsmasq[dbus,dhcp]
		net-firewall/iptables )
	consolekit? ( >=sys-auth/consolekit-0.9 )
	dhclient? ( >=net-misc/dhcp-4[client] )
	dhcpcd? ( net-misc/dhcpcd )
	elogind? ( >=sys-auth/elogind-219 )
	introspection? ( >=dev-libs/gobject-introspection-0.10.3:= )
	json? ( >=dev-libs/jansson-2.5[${MULTILIB_USEDEP}] )
	modemmanager? ( >=net-misc/modemmanager-0.7.991:0= )
	ncurses? ( >=dev-libs/newt-0.52.15 )
	nss? ( >=dev-libs/nss-3.11:=[${MULTILIB_USEDEP}] )
	!nss? ( gnutls? (
		dev-libs/libgcrypt:0=[${MULTILIB_USEDEP}]
		>=net-libs/gnutls-2.12:=[${MULTILIB_USEDEP}] ) )
	ofono? ( net-misc/ofono )
	ovs? (
		dev-libs/jansson
		net-misc/openvswitch
	)
	ppp? ( >=net-dialup/ppp-2.4.5:=[ipv6(+)] )
	resolvconf? ( virtual/resolvconf )
	selinux? ( sys-libs/libselinux )
	systemd? ( >=sys-apps/systemd-209:0= )
	teamd? (
		dev-libs/jansson
		>=net-misc/libteam-1.9
	)
"
RDEPEND="${COMMON_DEPEND}
	acct-group/plugdev
	|| (
		net-misc/iputils[arping(+)]
		net-analyzer/arping
	)
	wifi? (
		!vanilla? (
			|| (
				>=sys-apps/util-linux-2.31_rc1
				net-wireless/rfkill
			)
		)
		!iwd? ( >=net-wireless/wpa_supplicant-0.7.3-r3[dbus] )
		iwd? ( net-wireless/iwd )
	)
"
DEPEND="${COMMON_DEPEND}
	>=sys-kernel/linux-headers-3.18
"
BDEPEND="
	dev-util/gdbus-codegen
	!gtk-doc? ( dev-build/gtk-doc-am )
	gtk-doc? ( dev-util/gtk-doc )
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	introspection? (
		$(python_gen_any_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
		dev-lang/perl
		dev-libs/libxslt
	)
	vala? ( $(vala_depend) )
	test? (
		$(python_gen_any_dep '
			dev-python/dbus-python[${PYTHON_USEDEP}]
			dev-python/pygobject:3[${PYTHON_USEDEP}]')
	)
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.21.2.data-fix-the-id-net-driver-udev-rule.patch
	"${FILESDIR}"/${PN}-1.18.4-iwd1-compat.patch # included in 1.21.3+

	# From OpenEmbedded:
	# 	https://github.com/openembedded/meta-openembedded/commit/575c14ded56e1e97582a6df0921d19b4da630961
	"${FILESDIR}"/${PN}-1.14.6-do-not-create-settings-settings-property-documentation.patch

	# From systemd:
	# 	https://github.com/systemd/systemd/commit/b01f31954f1c7c4601925173ae2638b572224e9a
	"${FILESDIR}"/${PN}-1.30.6-turn-mempool-enabled-into-a-weak-symbol.patch
)

python_check_deps() {
	if use introspection; then
		python_has_version "dev-python/pygobject:3[${PYTHON_USEDEP}]" || return
	fi
	if use test; then
		python_has_version "dev-python/dbus-python[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/pygobject:3[${PYTHON_USEDEP}]"
	fi
}

pkg_setup() {
	if use connection-sharing; then
		if kernel_is lt 5 1; then
			CONFIG_CHECK="~NF_NAT_IPV4 ~NF_NAT_MASQUERADE_IPV4"
		else
			CONFIG_CHECK="~NF_NAT ~NF_NAT_MASQUERADE"
		fi
		linux-info_pkg_setup
	fi

	if use introspection || use test; then
		python-any-r1_pkg_setup
	fi
}

src_prepare() {
	DOC_CONTENTS="To modify system network connections without needing to enter the
		root password, add your user account to the 'plugdev' group."

	if has_version '<dev-libs/glib-2.44.0'; then
		eapply "${FILESDIR}"/${PN}-1.18.10-support-glib-2.42.patch
	fi

	use vala && vala_src_prepare
	gnome2_src_prepare
}

multilib_src_configure() {
	local myconf=(
		--disable-more-warnings
		--disable-static
		--localstatedir=/var
		--disable-lto
		--disable-config-plugin-ibft
		--disable-qt
		--without-netconfig
		--with-dbus-sys-dir=/etc/dbus-1/system.d
		# We need --with-libnm-glib (and dbus-glib dep) as reverse deps are
		# still not ready for removing that lib, bug #665338
		--with-libnm-glib
		$(multilib_native_with nmcli)
		--with-udev-dir="$(get_udevdir)"
		--with-config-plugins-default=keyfile
		--with-iptables=/sbin/iptables
		--with-ebpf=yes
		$(multilib_native_enable concheck)
		--with-crypto=$(usex nss nss gnutls)
		--with-session-tracking=$(multilib_native_usex systemd systemd $(multilib_native_usex elogind elogind $(multilib_native_usex consolekit consolekit no)))
		--with-suspend-resume=$(multilib_native_usex systemd systemd $(multilib_native_usex elogind elogind $(multilib_native_usex consolekit consolekit upower)))
		$(multilib_native_use_with audit libaudit)
		$(multilib_native_use_enable bluetooth bluez5-dun)
		$(use_with dhclient)
		$(use_with dhcpcd)
		$(multilib_native_use_enable introspection)
		$(multilib_native_use_enable gtk-doc)
		$(use_enable json json-validation)
		$(multilib_native_use_enable ppp)
		--without-libpsl
		$(multilib_native_use_with modemmanager modem-manager-1)
		$(multilib_native_use_with ncurses nmtui)
		$(multilib_native_use_with ofono)
		$(multilib_native_use_enable ovs)
		$(multilib_native_use_enable policykit polkit)
		$(multilib_native_use_enable policykit polkit-agent)
		$(multilib_native_use_with resolvconf)
		$(multilib_native_use_with selinux)
		$(multilib_native_use_with systemd systemd-journal)
		$(multilib_native_use_enable teamd teamdctl)
		$(multilib_native_use_enable test tests)
		$(multilib_native_use_enable vala)
		--without-valgrind
		$(multilib_native_use_with wifi iwd)
		$(multilib_native_use_with wext)
		$(multilib_native_use_enable wifi)
	)

	# Same hack as net-dialup/pptpd to get proper plugin dir for ppp, bug #519986
	if use ppp; then
		local PPPD_VER=`best_version net-dialup/ppp`
		PPPD_VER=${PPPD_VER#*/*-} #reduce it to ${PV}-${PR}
		PPPD_VER=${PPPD_VER%%[_-]*} # main version without beta/pre/patch/revision
		myconf+=( --with-pppd-plugin-dir=/usr/$(get_libdir)/pppd/${PPPD_VER} )
	fi

	# unit files directory needs to be passed only when systemd is enabled,
	# otherwise systemd support is not disabled completely, bug #524534
	use systemd && myconf+=( --with-systemdsystemunitdir="$(systemd_get_systemunitdir)" )

	if multilib_is_native_abi; then
		# work-around man out-of-source brokenness, must be done before configure
		ln -s "${S}/docs" docs || die
		ln -s "${S}/man" man || die
	fi

	ECONF_SOURCE=${S} runstatedir="/run" gnome2_src_configure "${myconf[@]}"
}

multilib_src_compile() {
	if multilib_is_native_abi; then
		emake
	else
		local targets=(
			libnm/libnm.la
			libnm-util/libnm-util.la
			libnm-glib/libnm-glib.la
			libnm-glib/libnm-glib-vpn.la
		)
		emake "${targets[@]}"
	fi
}

multilib_src_test() {
	if use test && multilib_is_native_abi; then
		python_setup
		virtx emake check
	fi
}

multilib_src_install() {
	if multilib_is_native_abi; then
		# Install completions at proper place, bug #465100
		gnome2_src_install completiondir="$(get_bashcompdir)"
		insinto /usr/lib/NetworkManager/conf.d #702476
		doins "${S}"/examples/nm-conf.d/31-mac-addr-change.conf
	else
		local targets=(
			install-libLTLIBRARIES
			install-libdeprecatedHEADERS
			install-libnm_glib_libnmvpnHEADERS
			install-libnm_glib_libnmincludeHEADERS
			install-libnm_util_libnm_util_includeHEADERS
			install-libnmincludeHEADERS
			install-nodist_libnm_glib_libnmincludeHEADERS
			install-nodist_libnm_glib_libnmvpnHEADERS
			install-nodist_libnm_util_libnm_util_includeHEADERS
			install-nodist_libnmincludeHEADERS
			install-pkgconfigDATA
		)
		emake DESTDIR="${D}" "${targets[@]}"
	fi
}

multilib_src_install_all() {
	! use systemd && readme.gentoo_create_doc

	if use vanilla; then
		if use elogind; then
			newinitd "${FILESDIR}"/init.d.NetworkManager-elogind NetworkManager
		else
			newinitd "${FILESDIR}"/init.d.NetworkManager NetworkManager
		fi
		newconfd "${FILESDIR}"/conf.d.NetworkManager NetworkManager
	else
		newinitd "${FILESDIR}"/init.d.NetworkManager-dhcpcd NetworkManager
		insinto /etc/NetworkManager
		doins "${FILESDIR}"/NetworkManager.conf
	fi

	# Need to keep the /etc/NetworkManager/dispatched.d for dispatcher scripts
	keepdir /etc/NetworkManager/dispatcher.d

	if use vanilla; then
		# Provide openrc net dependency only when nm is connected
		exeinto /etc/NetworkManager/dispatcher.d
		newexe "${FILESDIR}"/10-openrc-status-r4 10-openrc-status
		sed -e "s:@EPREFIX@:${EPREFIX}:g" \
			-i "${ED}/etc/NetworkManager/dispatcher.d/10-openrc-status" || die
	fi

	keepdir /etc/NetworkManager/system-connections
	chmod 0600 "${ED}"/etc/NetworkManager/system-connections/.keep* # bug #383765, upstream bug #754594

	# Allow users in plugdev group to modify system connections
	insinto /usr/share/polkit-1/rules.d/
	doins "${FILESDIR}"/01-org.freedesktop.NetworkManager.settings.modify.system.rules

	if use iwd; then
		# This goes to $nmlibdir/conf.d/ and $nmlibdir is '${prefix}'/lib/$PACKAGE, thus always lib, not get_libdir
		cat <<-EOF > "${ED}"/usr/lib/NetworkManager/conf.d/iwd.conf || die
		[device]
		wifi.backend=iwd
		EOF
	fi

	# Empty
	rmdir "${ED}"/var{/lib{/NetworkManager,},} || die
}

pkg_postinst() {
	udev_reload

	gnome2_pkg_postinst
	systemd_reenable NetworkManager.service
	! use systemd && readme.gentoo_print_elog

	if [[ -e "${EROOT}/etc/NetworkManager/nm-system-settings.conf" ]]; then
		ewarn "The ${PN} system configuration file has moved to a new location."
		ewarn "You must migrate your settings from ${EROOT}/etc/NetworkManager/nm-system-settings.conf"
		ewarn "to ${EROOT}/etc/NetworkManager/NetworkManager.conf"
		ewarn
		ewarn "After doing so, you can remove ${EROOT}/etc/NetworkManager/nm-system-settings.conf"
	fi

	# NM fallbacks to plugin specified at compile time (upstream bug #738611)
	# but still show a warning to remember people to have cleaner config file
	if [[ -e "${EROOT}/etc/NetworkManager/NetworkManager.conf" ]]; then
		if grep plugins "${EROOT}/etc/NetworkManager/NetworkManager.conf" | grep -q ifnet; then
			ewarn
			ewarn "You seem to use 'ifnet' plugin in ${EROOT}/etc/NetworkManager/NetworkManager.conf"
			ewarn "Since it won't be used, you will need to stop setting ifnet plugin there."
			ewarn
		fi
	fi

	# NM shows lots of errors making nmcli almost unusable, bug #528748 upstream bug #690457
	if grep -r "psk-flags=1" "${EROOT}"/etc/NetworkManager/; then
		ewarn "You have psk-flags=1 setting in above files, you will need to"
		ewarn "either reconfigure affected networks or, at least, set the flag"
		ewarn "value to '0'."
	fi
}

pkg_postrm() {
	udev_reload
}
