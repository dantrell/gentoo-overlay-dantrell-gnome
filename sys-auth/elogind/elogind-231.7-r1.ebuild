# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools linux-info pam udev xdg-utils

DESCRIPTION="The systemd project's logind, extracted to a standalone package"
HOMEPAGE="https://github.com/elogind/elogind"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC0-1.0 LGPL-2.1+ public-domain"
SLOT="0"
KEYWORDS="*"

IUSE="acl debug pam policykit selinux"

COMMON_DEPEND="
	sys-apps/util-linux
	sys-libs/libcap
	virtual/libudev:=
	acl? ( sys-apps/acl )
	pam? ( sys-libs/pam )
	selinux? ( sys-libs/libselinux )
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	dev-util/gperf
	dev-util/intltool
	dev-build/libtool
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	!sys-apps/systemd
"
PDEPEND="
	sys-apps/dbus
	policykit? ( sys-auth/polkit )
"

PATCHES=(
	"${FILESDIR}"/${PN}-226.4-docs.patch
	"${FILESDIR}"/${PN}-233.7-xlocale.h.patch
	"${FILESDIR}"/${PN}-233.7-missing-syscall-when-adding-syscall-replacements-use-different-names.patch
)

pkg_setup() {
	local CONFIG_CHECK="~CGROUPS ~EPOLL ~INOTIFY_USER ~SIGNALFD ~TIMERFD"

	use kernel_linux && linux-info_pkg_setup
}

src_prepare() {
	default
	eautoreconf # Makefile.am patched by "${FILESDIR}"/${P}-docs.patch
	xdg_environment_reset
}

src_configure() {
	econf \
		--with-pamlibdir=$(getpam_mod_dir) \
		--with-udevrulesdir="$(get_udevdir)"/rules.d \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--with-rootlibdir="${EPREFIX}"/$(get_libdir) \
		--with-rootprefix="${EPREFIX}/" \
		--with-rootlibexecdir="${EPREFIX}"/$(get_libdir)/elogind \
		--enable-smack \
		--with-cgroup-controller=openrc \
		--disable-lto \
		--without-kill-user-processes \
		$(use_enable debug debug elogind) \
		$(use_enable acl) \
		$(use_enable pam) \
		$(use_enable selinux)
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die

	newinitd "${FILESDIR}"/${PN}.init ${PN}

	sed -e "s/@libdir@/$(get_libdir)/" "${FILESDIR}"/${PN}.conf.in > ${PN}.conf || die
	newconfd ${PN}.conf ${PN}
}

pkg_postinst() {
	if [ "$(rc-config list boot | grep elogind)" != "" ]; then
		ewarn "elogind is currently started from boot runlevel."
	elif [ "$(rc-config list default | grep elogind)" != "" ]; then
		ewarn "elogind is currently started from default runlevel."
		ewarn "Please remove elogind from the default runlevel and"
		ewarn "add it to the boot runlevel by:"
		ewarn "# rc-update del elogind default"
		ewarn "# rc-update add elogind boot"
	else
		ewarn "elogind is currently not started from any runlevel."
		ewarn "You may add it to the boot runlevel by:"
		ewarn "# rc-update add elogind boot"
	fi
	ewarn "Alternatively you can leave elogind out of any"
	ewarn "runlevel. It will then be started automatically"
	if use pam; then
		ewarn "when the first service calls it via dbus, or the"
		ewarn "first user logs into the system."
	else
		ewarn "when the first service calls it via dbus."
	fi
}
