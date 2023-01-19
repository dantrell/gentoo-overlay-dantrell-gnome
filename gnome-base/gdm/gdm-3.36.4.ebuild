# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools gnome2 pam readme.gentoo-r1 systemd udev

DESCRIPTION="GNOME Display Manager for managing graphical display servers and user logins"
HOMEPAGE="https://wiki.gnome.org/Projects/GDM"
SRC_URI="${SRC_URI}
	branding? ( https://www.mail-archive.com/tango-artists@lists.freedesktop.org/msg00043/tango-gentoo-v1.1.tar.gz )
"

LICENSE="
	GPL-2+
	branding? ( CC-BY-SA-4.0 )
"
SLOT="0"
KEYWORDS="*"

IUSE="accessibility audit bluetooth-sound branding elogind fprint +introspection plymouth selinux smartcard systemd tcpd test wayland xinerama"
REQUIRED_USE="
	?? ( elogind systemd )
	wayland? ( || ( elogind systemd ) )
"

RESTRICT="!test? ( test )"

# NOTE: x11-base/xorg-server dep is for X_SERVER_PATH etc, bug #295686
# nspr used by smartcard extension
# dconf, dbus and g-s-d are needed at install time for dconf update
# keyutils is automagic dep that makes autologin unlock login keyring when all the passwords match (disk encryption, user pw and login keyring)
# dbus-run-session used at runtime
# We need either systemd or >=openrc-0.12 to restart gdm properly, bug #463784
COMMON_DEPEND="
	app-text/iso-codes
	>=dev-libs/glib-2.44:2
	dev-libs/libgudev:=
	>=x11-libs/gtk+-2.91.1:3
	>=gnome-base/dconf-0.20
	>=gnome-base/gnome-settings-daemon-3.1.4
	gnome-base/gsettings-desktop-schemas
	>=media-libs/fontconfig-2.5.0:1.0
	>=media-libs/libcanberra-0.4[gtk3]
	sys-apps/dbus
	>=sys-apps/accountsservice-0.6.35

	x11-base/xorg-server
	x11-libs/libXau
	x11-libs/libX11
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libxcb
	>=x11-misc/xdg-utils-1.0.2-r3

	sys-libs/pam
	sys-apps/keyutils:=
	elogind? ( sys-auth/elogind[pam] )
	systemd? ( sys-apps/systemd[pam] )

	sys-auth/pambase[elogind?,systemd?]

	audit? ( sys-process/audit )
	introspection? ( >=dev-libs/gobject-introspection-0.9.12:= )
	plymouth? ( sys-boot/plymouth )
	selinux? ( sys-libs/libselinux )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	xinerama? ( x11-libs/libXinerama )
"
# XXX: These deps are from session and desktop files in data/ directory
# fprintd is used via dbus by gdm-fingerprint-extension
# gnome-session-3.6 needed to avoid freezing with orca
RDEPEND="${COMMON_DEPEND}
	acct-group/gdm
	acct-user/gdm
	>=gnome-base/gnome-session-3.6
	>=gnome-base/gnome-shell-3.1.90
	x11-apps/xhost

	accessibility? (
		>=app-accessibility/orca-3.10
		gnome-extra/mousetweaks )
	fprint? ( sys-auth/fprintd[pam] )

	!gnome-extra/fast-user-switch-applet
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.1.2
	dev-util/gdbus-codegen
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	x11-base/xorg-proto
	test? ( >=dev-libs/check-0.9.4 )
	app-text/yelp-tools
" # yelp-tools needed for eautoreconf to not lose help docs (m4_ifdeffed YELP_HELP_INIT call and setup)

DOC_CONTENTS="
	To make GDM start at boot with systemd, run:\n
	# systemctl enable gdm.service\n
	\n
	To make GDM start at boot with OpenRC, edit /etc/conf.d to have
	DISPLAYMANAGER=\"gdm\" and enable the xdm service:\n
	# rc-update add xdm
	\n
	For passwordless login to unlock your keyring, you need to install
	sys-auth/pambase with USE=gnome-keyring and set an empty password
	on your keyring. Use app-crypt/seahorse for that.\n
	\n
	You may need to install app-crypt/coolkey and sys-auth/pam_pkcs11
	for smartcard support
"

src_prepare() {
	# ssh-agent handling must be done at xinitrc.d, bug #220603
	eapply "${FILESDIR}"/${PN}-2.32.0-xinitrc-ssh-agent.patch

	# Gentoo does not have a fingerprint-auth pam stack
	eapply "${FILESDIR}"/${PN}-3.8.4-fingerprint-auth.patch

	if use elogind; then
		eapply "${FILESDIR}"/${PN}-3.30.3-support-elogind.patch
		eapply "${FILESDIR}"/${PN}-3.32.0-enable-elogind.patch
	fi

	if ! use wayland; then
		eapply "${FILESDIR}"/${PN}-3.30.0-prioritize-xorg.patch
	else
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/gdm/commit/5cd78602d3d4c8355869151875fc317e8bcd5f08
		eapply "${FILESDIR}"/${PN}-3.36.3-data-disable-wayland-for-proprietary-nvidia-machines.patch
	fi

	# Wait for DRM device before trying to start it, bug #613222
	eapply "${FILESDIR}"/${PN}-3.30.2-gdm3-service-wait-for-drm-device-before-trying-to-start-it.patch

	# Show logo when branding is enabled
	use branding && eapply "${FILESDIR}"/${PN}-3.30.3-logo.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	# PAM is the only auth scheme supported
	# even though configure lists shadow and crypt
	# they don't have any corresponding code.
	# --with-at-spi-registryd-directory= needs to be passed explicitly because
	# of https://bugzilla.gnome.org/show_bug.cgi?id=607643#c4
	# Xevie is obsolete, bug #482304
	local myconf=(
		--enable-gdm-xsession
		--enable-user-display-server
		--with-run-dir=/run/gdm
		--localstatedir="${EPREFIX}"/var
		--disable-static
		--with-xdmcp=yes
		--enable-authentication-scheme=pam
		--with-default-pam-config=exherbo
		--with-pam-mod-dir=$(getpam_mod_dir)
		--with-udevdir=$(get_udevdir)
		--with-at-spi-registryd-directory="${EPREFIX}"/usr/libexec
		--without-xevie
		$(use_enable systemd systemd-journal)
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
		$(use_with audit libaudit)
		--enable-ipv6
		$(use_with plymouth)
		$(use_with selinux)
		$(use_with tcpd tcp-wrappers)
		$(use_enable wayland wayland-support)
		$(use_with xinerama)
		--with-initial-vt=7
	)

	gnome2_src_configure "${myconf[@]}"
}

src_install() {
	gnome2_src_install

	if ! use accessibility ; then
		rm "${ED}"/usr/share/gdm/greeter/autostart/orca-autostart.desktop || die
	fi

	exeinto /etc/X11/xinit/xinitrc.d
	newexe "${FILESDIR}"/49-keychain-r1 49-keychain
	newexe "${FILESDIR}"/50-ssh-agent-r1 50-ssh-agent

	if ! use bluetooth-sound ; then
		# Workaround https://gitlab.freedesktop.org/pulseaudio/pulseaudio/merge_requests/10
		# bug #679526
		insinto /var/lib/gdm/.config/pulse
		doins "${FILESDIR}"/default.pa
	fi

	# install XDG_DATA_DIRS gdm changes
	echo 'XDG_DATA_DIRS="/usr/share/gdm"' > 99xdg-gdm
	doenvd 99xdg-gdm

	use branding && newicon "${WORKDIR}/tango-gentoo-v1.1/scalable/gentoo.svg" gentoo-gdm.svg

	readme.gentoo_create_doc
}

pkg_postinst() {
	gnome2_pkg_postinst

	# bug #669146; gdm may crash if /var/lib/gdm subdirs are not owned by gdm:gdm
	local d ret
	ret=0
	ebegin "Fixing ${EROOT}/var/lib/gdm ownership"
	chown --no-dereference gdm:gdm "${EROOT}var/lib/gdm" || ret=1
	for d in "${EROOT}var/lib/gdm/"{.cache,.color,.config,.dbus,.local}; do
		[[ ! -e "${d}" ]] || chown --no-dereference -R gdm:gdm "${d}" || ret=1
	done
	eend ${ret}

	use systemd && systemd_reenable gdm.service
	readme.gentoo_print_elog
}
