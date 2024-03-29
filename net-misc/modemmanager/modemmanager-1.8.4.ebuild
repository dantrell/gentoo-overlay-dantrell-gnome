# Distributed under the terms of the GNU General Public License v2

EAPI="8"
VALA_USE_DEPEND="vapigen"

inherit autotools gnome2 readme.gentoo-r1 systemd toolchain-funcs udev vala

DESCRIPTION="Modem and mobile broadband management libraries"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/ModemManager/"
SRC_URI="https://www.freedesktop.org/software/ModemManager/ModemManager-${PV}.tar.xz"

LICENSE="GPL-2+"
SLOT="0/1" # subslot = dbus interface version, i.e. N in org.freedesktop.ModemManager${N}
KEYWORDS="*"

IUSE="ck elogind +introspection mbim policykit +qmi systemd +udev vala"
REQUIRED_USE="
	?? ( ck elogind systemd )
	vala? ( introspection )
"

DEPEND="
	>=dev-libs/glib-2.36.0:2
	ck? ( >=sys-power/upower-0.99:=[ck] )
	udev? ( >=dev-libs/libgudev-230:= )
	introspection? ( >=dev-libs/gobject-introspection-0.9.6:= )
	mbim? ( >=net-libs/libmbim-1.16.0 )
	policykit? ( >=sys-auth/polkit-0.106[introspection] )
	qmi? ( >=net-libs/libqmi-1.20.0:= )
	elogind? ( sys-auth/elogind )
	systemd? ( >=sys-apps/systemd-209 )
"
RDEPEND="${DEPEND}
	policykit? ( acct-group/plugdev )
"
BDEPEND="
	dev-util/gdbus-codegen
	>=dev-build/gtk-doc-am-1
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

S="${WORKDIR}/ModemManager-${PV}"

src_prepare() {
	DOC_CONTENTS="
		If your USB modem shows up only as a storage device when you plug it in,
		then you should install sys-apps/usb_modeswitch, which will automatically
		switch it over to USB modem mode whenever you plug it in.\n"

	if use policykit; then
		DOC_CONTENTS+="\nTo control your modem without needing to enter the root password,
			add your user account to the 'plugdev' group."
	fi

	if ! use elogind; then
		# From ModemManager:
		# 	https://cgit.freedesktop.org/ModemManager/ModemManager/commit/?id=1f13909d9b59176afd9cec32cfbd623b44ec8d80
		# 	https://cgit.freedesktop.org/ModemManager/ModemManager/commit/?id=ae2988da933f39d8983c94aaeef3c1b6f98f3e4e
		# 	https://cgit.freedesktop.org/ModemManager/ModemManager/commit/?id=6197a06931ffd197b4f66b92c4d729b5911e0e36
		eapply "${FILESDIR}"/${PN}-1.8.2-restore-deprecated-code.patch

		eautoreconf
	fi

	use vala && vala_setup
	gnome2_src_prepare
}

src_configure() {
	local myconf=(
		--disable-more-warnings
		--disable-static
		--with-dist-version=${PVR}
		--with-udev-base-dir="$(get_udevdir)"
		$(use_with udev)
		$(use_enable introspection)
		$(use_with mbim)
		$(use_with policykit polkit)
		$(use_with systemd systemd-journal)
		$(use_with qmi)
		$(use_enable vala)
	)
	if ! use elogind; then
		myconf+=(
			$(usex systemd --with-suspend-resume=systemd $(usex ck --with-suspend-resume=upower --with-suspend-resume=no))
		)
	fi
	if use elogind; then
		local pkgconfig="$(tc-getPKG_CONFIG)"
		myconf+=(
			--with-systemd-suspend-resume
			LIBSYSTEMD_LOGIN_CFLAGS="$(${pkgconfig} --cflags "libelogind")"
			LIBSYSTEMD_LOGIN_LIBS="$(${pkgconfig} --libs "libelogind")"
		)
	fi
	gnome2_src_configure "${myconf[@]}"
}

src_install() {
	gnome2_src_install

	# Allow users in plugdev group full control over their modem
	if use policykit; then
		insinto /usr/share/polkit-1/rules.d/
		doins "${FILESDIR}"/01-org.freedesktop.ModemManager1.rules
	fi

	readme.gentoo_create_doc

	newinitd "${FILESDIR}"/modemmanager.initd modemmanager
}

pkg_postinst() {
	gnome2_pkg_postinst

	# The polkit rules file moved to /usr/share
	old_rules="${EROOT}/etc/polkit-1/rules.d/01-org.freedesktop.ModemManager.rules"
	if [[ -f "${old_rules}" ]]; then
		case "$(md5sum ${old_rules})" in
		  c5ff02532cb1da2c7545c3069e5d0992* | 5c50f0dc603c0a56e2851a5ce9389335* )
			# Automatically delete the old rules.d file if the user did not change it
			elog
			elog "Removing old ${old_rules} ..."
			rm -f "${old_rules}" || eerror "Failed, please remove ${old_rules} manually"
			;;
		  * )
			elog "The ${old_rules}"
			elog "file moved to /usr/share/polkit-1/rules.d/ in >=modemmanager-0.5.2.0-r2"
			elog "If you edited ${old_rules}"
			elog "without changing its behavior, you may want to remove it."
			;;
		esac
	fi

	if ! use udev; then
		ewarn "You have built ModemManager without udev support. You may have to teach it"
		ewarn "about your modem port manually."
	fi

	use udev && udev_reload

	systemd_reenable ModemManager.service

	readme.gentoo_print_elog
}

pkg_postrm() {
	use udev && udev_reload
}
