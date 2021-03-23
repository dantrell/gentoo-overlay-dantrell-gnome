# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit bash-completion-r1 toolchain-funcs check-reqs gnome2-utils systemd udev vala meson multilib-minimal

DESCRIPTION="System service to accurately color manage input and output devices"
HOMEPAGE="https://www.freedesktop.org/software/colord/"
SRC_URI="https://www.freedesktop.org/software/colord/releases/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0/2" # subslot = libcolord soname version
KEYWORDS=""

# We prefer policykit enabled by default, bug #448058
IUSE="argyllcms examples extra-print-profiles +gusb +introspection +policykit scanner systemd +udev vala"
REQUIRED_USE="
	gusb? ( udev )
	scanner? ( udev )
	vala? ( introspection )
"

# FIXME: needs pre-installed dbus service files
RESTRICT="test"

DEPEND="
	dev-db/sqlite:3=[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.46.0:2[${MULTILIB_USEDEP}]
	>=media-libs/lcms-2.6:2=[${MULTILIB_USEDEP}]
	argyllcms? ( media-gfx/argyllcms )
	gusb? ( >=dev-libs/libgusb-0.2.7[introspection?,${MULTILIB_USEDEP}] )
	introspection? ( >=dev-libs/gobject-introspection-0.9.8:= )
	policykit? ( >=sys-auth/polkit-0.104 )
	scanner? (
		media-gfx/sane-backends
		sys-apps/dbus
	)
	systemd? ( >=sys-apps/systemd-44:0= )
	udev? (
		dev-libs/libgudev:=[${MULTILIB_USEDEP}]
		virtual/libudev:=[${MULTILIB_USEDEP}]
		virtual/udev
	)
"
RDEPEND="${DEPEND}
	acct-group/colord
	acct-user/colord
	!<=media-gfx/colorhug-client-0.1.13
	!media-gfx/shared-color-profiles
"
BDEPEND="
	acct-group/colord
	acct-user/colord
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.35
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	extra-print-profiles? ( media-gfx/argyllcms )
	vala? ( $(vala_depend) )
"
# These dependencies are required to build native build-time programs.
BDEPEND="${BDEPEND}
	dev-libs/glib:2
	media-libs/lcms
"

# According to upstream comment in colord.spec.in, building the extra print
# profiles requires >=4G of memory
CHECKREQS_MEMORY="4G"

pkg_pretend() {
	use extra-print-profiles && check-reqs_pkg_pretend
}

pkg_setup() {
	use extra-print-profiles && check-reqs_pkg_setup
}

src_prepare() {
	eapply_user
	xdg_src_prepare
	gnome2_environment_reset
}

multilib_src_configure() {
	local emesonargs=(
		-Ddaemon=$(multilib_is_native_abi && echo true || echo false)
		-Dbash_completion=false
		-Dsession_example=false
		-Dlibcolordcompat=true
		-Ddaemon_user=colord
		-Dinstalled_tests=false
		-Dtests=false
		-Dargyllcms_sensor=$(multilib_native_usex argyllcms true false)
		-Dprint_profiles=$(multilib_native_usex extra-print-profiles true false)
		-Dreverse=false
		-Dsane=$(multilib_native_usex scanner true false)
		-Dsystemd=$(multilib_native_usex systemd true false)
		-Dudev_rules=$(multilib_native_usex udev true false)
		-Dvapi=$(multilib_native_usex vala  true false)
		-Ddocs=false
	)

	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	einstalldocs

	newbashcomp data/colormgr colormgr

	# Ensure config and profile directories exist and /var/lib/colord/*
	# is writable by colord user
	keepdir /var/lib/color{,d}/icc
	fowners colord:colord /var/lib/colord{,/icc}

	if use examples; then
		docinto examples
		dodoc examples/*.c
	fi
}
