# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit autotools linux-info python-single-r1 systemd udev multilib-minimal #readme.gentoo-r1

DESCRIPTION="Bluetooth Tools and System Daemons for Linux"
HOMEPAGE="http://www.bluez.org"
SRC_URI="https://www.kernel.org/pub/linux/bluetooth/${P}.tar.xz"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0/3"
KEYWORDS="*"

IUSE="btpclient cups doc debug deprecated extra-tools experimental +mesh midi +obex +readline selinux systemd test test-programs +udev user-session"
# Since this release all remaining extra-tools need readline support, but this could
# change in the future, hence, this REQUIRED_USE constraint could be dropped
# again in the future.
# btpclient needs mesh, bug #790587
REQUIRED_USE="
	btpclient? ( mesh )
	extra-tools? ( deprecated readline )
	test? ( ${PYTHON_REQUIRED_USE} )
	test-programs? ( ${PYTHON_REQUIRED_USE} )
"

RESTRICT="!test? ( test )"

TEST_DEPS="${PYTHON_DEPS}
	$(python_gen_cond_dep '
		>=dev-python/dbus-python-1[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	dev-python/docutils
	virtual/pkgconfig
	test? ( ${TEST_DEPS} )
"
DEPEND="
	>=dev-libs/glib-2.28:2[${MULTILIB_USEDEP}]
	btpclient? ( >=dev-libs/ell-0.39 )
	cups? ( net-print/cups:= )
	mesh? (
		>=dev-libs/ell-0.39
		>=dev-libs/json-c-0.13:=
		sys-libs/readline:0=
	)
	midi? ( media-libs/alsa-lib )
	obex? ( dev-libs/libical:= )
	readline? ( sys-libs/readline:0= )
	systemd? (
		>=sys-apps/dbus-1.6:=[user-session=]
		sys-apps/systemd
	)
	!systemd? ( >=sys-apps/dbus-1.6:= )
	udev? ( >=virtual/udev-172 )
"
RDEPEND="${DEPEND}
	deprecated? ( !net-wireless/bluez-hcidump )
	selinux? ( sec-policy/selinux-bluetooth )
	test-programs? ( ${TEST_DEPS} )
"

PATCHES=(
	# Try both udevadm paths to cover udev/systemd vs. eudev locations (#539844)
	# http://www.spinics.net/lists/linux-bluetooth/msg58739.html
	# https://bugs.gentoo.org/539844
	# https://github.com/bluez/bluez/issues/268
	"${FILESDIR}"/${PN}-udevadm-path-r1.patch

	# Fedora patches
	# http://www.spinics.net/lists/linux-bluetooth/msg40136.html
	"${FILESDIR}"/${PN}-0001-obex-Use-GLib-helper-function-to-manipulate-paths.patch

	# https://lore.kernel.org/linux-bluetooth/20220901110719.176944-1-hadess@hadess.net/T/#m9c08d004cd5422783ee1d93154f42303bba9169f
	"${FILESDIR}"/${PN}-5.66-power-state-adapter-property.patch

	# Fixed in next release
	"${FILESDIR}"/${P}-transient-hostname-fix.patch

	# https://github.com/nilfs-dev/nilfs-utils/commit/115fe4b976858c487cf83065f513d8626089579a
	# https://bugs.gentoo.org/888467
	"${FILESDIR}"/${PN}-5.66-musl-max-input.patch
)

pkg_setup() {
	# From http://www.linuxfromscratch.org/blfs/view/svn/general/bluez.html
	# to prevent bugs like:
	# https://bugzilla.kernel.org/show_bug.cgi?id=196621
	CONFIG_CHECK="~NET ~BT ~BT_RFCOMM ~BT_RFCOMM_TTY ~BT_BNEP ~BT_BNEP_MC_FILTER
		~BT_BNEP_PROTO_FILTER ~BT_HIDP ~CRYPTO_USER_API_HASH ~CRYPTO_USER_API_SKCIPHER ~RFKILL"
	# https://bugzilla.kernel.org/show_bug.cgi?id=196621
	# https://bugzilla.kernel.org/show_bug.cgi?id=206815
	if use mesh || use test; then
		CONFIG_CHECK="${CONFIG_CHECK} ~CRYPTO_USER
		~CRYPTO_USER_API ~CRYPTO_USER_API_AEAD ~CRYPTO_AES ~CRYPTO_CCM ~CRYPTO_AEAD ~CRYPTO_CMAC
		~CRYPTO_MD5 ~CRYPTO_SHA1 ~KEY_DH_OPERATIONS"
	fi
	linux-info_pkg_setup

	if use test || use test-programs; then
		python-single-r1_pkg_setup
	fi

	if ! use udev; then
		ewarn
		ewarn "You are installing ${PN} with USE=-udev. This means various bluetooth"
		ewarn "devices and adapters from Apple, Dell, Logitech etc. will not work,"
		ewarn "and hid2hci will not be available."
		ewarn
	fi
}

src_prepare() {
	default

	# http://www.spinics.net/lists/linux-bluetooth/msg38490.html
	if ! use user-session || ! use systemd; then
		eapply "${FILESDIR}"/${PN}-0001-Allow-using-obexd-without-systemd-in-the-user-session-r2.patch
	fi

	eautoreconf

	if use cups; then
		# Only not .am to not need to run eautoreconf only because of this
		sed -i \
			-e "s:cupsdir = \$(libdir)/cups:cupsdir = $(cups-config --serverbin):" \
			Makefile.{in,tools} || die
	fi

	multilib_copy_sources
}

multilib_src_configure() {
	local myconf=(
		# readline is automagic when client is enabled
		# --enable-client always needs readline, bug #504038
		# --enable-mesh is handled in the same way
		ac_cv_header_readline_readline_h=$(multilib_native_usex readline)
		ac_cv_header_readline_readline_h=$(multilib_native_usex mesh)
	)

	if ! multilib_is_native_abi; then
		myconf+=(
			# deps not used for the library
			{DBUS,GLIB}_{CFLAGS,LIBS}=' '
		)
	fi

	econf \
		--localstatedir=/var \
		--disable-android \
		--enable-datafiles \
		--enable-optimization \
		$(use_enable debug) \
		--enable-pie \
		--enable-threads \
		--enable-library \
		--enable-tools \
		--enable-manpages \
		--enable-monitor \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
		--with-systemduserunitdir="$(systemd_get_userunitdir)" \
		$(multilib_native_use_enable btpclient) \
		$(multilib_native_use_enable btpclient external-ell) \
		$(multilib_native_use_enable cups) \
		$(multilib_native_use_enable deprecated) \
		$(multilib_native_use_enable experimental) \
		$(multilib_native_use_enable mesh) \
		$(multilib_native_use_enable mesh external-ell) \
		$(multilib_native_use_enable midi) \
		$(multilib_native_use_enable obex) \
		$(multilib_native_use_enable readline client) \
		$(multilib_native_use_enable systemd) \
		$(multilib_native_use_enable test-programs test) \
		$(multilib_native_use_enable udev) \
		$(multilib_native_use_enable udev hid2hci) \
		$(multilib_native_use_enable udev sixaxis)
}

multilib_src_compile() {
	if multilib_is_native_abi; then
		default
	else
		emake -f Makefile -f - libs \
			<<<'libs: $(lib_LTLIBRARIES)'
	fi
}

multilib_src_test() {
	multilib_is_native_abi && default
}

multilib_src_install() {
	if multilib_is_native_abi; then
		emake DESTDIR="${D}" install

		# Only install extra-tools when relevant USE flag is enabled
		if use extra-tools; then
			ewarn "Upstream doesn't support using this tools and their bugs are"
			ewarn "likely to be ignored forever, also they can break without"
			ewarn "previous announcement."
			ewarn "Upstream also states all this tools are not really needed,"
			ewarn "then, if you still need to rely on them, you must ask them"
			ewarn "to either install that tool by default or add the needed"
			ewarn "functionality to the existing 'official' tools."
			ewarn "Please report this issues to:"
			ewarn "http://www.bluez.org/development/lists/"

			# Upstream doesn't install this, bug #524640
			# http://permalink.gmane.org/gmane.linux.bluez.kernel/53115
			# http://comments.gmane.org/gmane.linux.bluez.kernel/54564
			dobin tools/btmgmt
			# gatttool is only built with readline, bug #530776
			# https://bugzilla.redhat.com/show_bug.cgi?id=1141909
			# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=720486
			# https://bugs.archlinux.org/task/37686
			dobin attrib/gatttool
			# https://bugzilla.redhat.com/show_bug.cgi?id=1699680
			dobin tools/avinfo
		fi

		# Not installed by default after being built, bug #666756
		use btpclient && dobin tools/btpclient

		# Unittests are not that useful once installed, so make them optional
		if use test-programs; then
			# Drop python2 only test tools
			# https://bugzilla.kernel.org/show_bug.cgi?id=206819
			rm "${ED}"/usr/$(get_libdir)/bluez/test/simple-player || die
			# https://bugzilla.kernel.org/show_bug.cgi?id=206821
			rm "${ED}"/usr/$(get_libdir)/bluez/test/test-hfp || die
			# https://bugzilla.kernel.org/show_bug.cgi?id=206823
			rm "${ED}"/usr/$(get_libdir)/bluez/test/test-sap-server	|| die

			python_fix_shebang "${ED}"/usr/$(get_libdir)/bluez/test

			for i in $(find "${ED}"/usr/$(get_libdir)/bluez/test -maxdepth 1 -type f ! -name "*.*"); do
				dosym "${i}" /usr/bin/bluez-"${i##*/}"
			done
		fi
	else
		emake DESTDIR="${D}" \
			install-pkgincludeHEADERS \
			install-libLTLIBRARIES \
			install-pkgconfigDATA
	fi
}

multilib_src_install_all() {
	# We need to ensure obexd can be spawned automatically by systemd
	# when user-session is enabled:
	# http://marc.info/?l=linux-bluetooth&m=148096094716386&w=2
	# https://bugs.gentoo.org/577842
	# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=804908
	# https://bugs.archlinux.org/task/45816
	# https://bugzilla.redhat.com/show_bug.cgi?id=1318441
	# https://bugzilla.redhat.com/show_bug.cgi?id=1389347
	if use user-session && use systemd; then
		dosym obex.service /usr/lib/systemd/user/dbus-org.bluez.obex.service
	fi

	find "${D}" -name '*.la' -type f -delete || die

	keepdir /var/lib/bluetooth

	# Upstream don't want people to play with them
	# But we keep installing them due to 'historical' reasons
	insinto /etc/bluetooth
	local d
	for d in input network; do
		doins profiles/${d}/${d}.conf
	done
	# Setup auto enable as Fedora does for allowing to use
	# keyboards/mouse as soon as possible
	sed -i 's/#\[Policy\]$/\[Policy\]/; s/#AutoEnable=false/AutoEnable=true/' src/main.conf || die
	doins src/main.conf

	newinitd "${FILESDIR}"/bluetooth-init.d-r5 bluetooth
	newconfd "${FILESDIR}"/bluetooth-conf.d bluetooth

	einstalldocs
	use doc && dodoc doc/*.txt
	# Upstream dropped the example files
	# Install .json files as examples to be used by meshctl
	#if use mesh; then
		#dodoc tools/mesh-gatt/*.json
	#	local DOC_CONTENTS="Some example .json files were installed into
	#	/usr/share/doc/${PF} to be used with meshctl. Feel free to
	#	uncompress and copy them to ~/.config/meshctl to use them."
	#	readme.gentoo_create_doc
	#fi
}

pkg_postinst() {
	use udev && udev_reload
	systemd_reenable bluetooth.service

	has_version net-dialup/ppp || elog "To use dial up networking you must install net-dialup/ppp"
	#use mesh && readme.gentoo_print_elog
}

pkg_postrm() {
	use udev && udev_reload
}
