# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME2_EAUTORECONF="yes"
VALA_USE_DEPEND="vapigen"

inherit bash-completion-r1 check-reqs gnome2 systemd udev vala multilib-minimal toolchain-funcs

DESCRIPTION="System service to accurately color manage input and output devices"
HOMEPAGE="https://www.freedesktop.org/software/colord/"
SRC_URI="https://www.freedesktop.org/software/colord/releases/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0/2" # subslot = libcolord soname version
KEYWORDS="*"

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
	>=dev-libs/glib-2.36:2[${MULTILIB_USEDEP}]
	>=media-libs/lcms-2.6:2=[${MULTILIB_USEDEP}]
	argyllcms? ( media-gfx/argyllcms )
	gusb? ( >=dev-libs/libgusb-0.2.2[introspection?,${MULTILIB_USEDEP}] )
	introspection? ( >=dev-libs/gobject-introspection-0.9.8:= )
	policykit? ( >=sys-auth/polkit-0.103 )
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
	>=dev-build/gtk-doc-am-1.9
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
	# Adapt to Gentoo paths
	sed -i -e 's/spotread/argyll-spotread/' \
		src/sensors/cd-sensor-argyll.c \
		configure.ac || die

	use vala && vala_src_prepare
	gnome2_src_prepare
	multilib_copy_sources
}

multilib_src_configure() {
	# Reverse tools require gusb
	# bash-completion test does not work on gentoo
	local myconf=(
		--disable-bash-completion
		--disable-examples
		--disable-static
		--enable-libcolordcompat
		--with-daemon-user=colord
		--localstatedir="${EPREFIX}"/var
		$(multilib_native_use_enable argyllcms argyllcms-sensor)
		$(multilib_native_use_enable extra-print-profiles print-profiles)
		$(multilib_native_usex extra-print-profiles COLPROF="$(type -P argyll-colprof)" "")
		$(use_enable gusb)
		$(multilib_native_use_enable gusb reverse)
		$(multilib_native_use_enable introspection)
		$(multilib_native_use_enable policykit polkit)
		$(multilib_native_use_enable scanner sane)
		$(multilib_native_use_enable systemd systemd-login)
		$(use_enable udev)
		--with-udevrulesdir="$(get_udevdir)"/rules.d
		$(multilib_native_use_enable vala)
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
	)

	if ! multilib_is_native_abi; then
		# disable some extraneous checks
		myconf+=(
			SQLITE_{CFLAGS,LIBS}=' '
			GUDEV_{CFLAGS,LIBS}=' '
		)
	fi

	ECONF_SOURCE=${S} \
	gnome2_src_configure "${myconf[@]}"
}

multilib_src_compile() {
	if multilib_is_native_abi; then
		gnome2_src_compile
	else
		emake -C lib/colord
		use gusb && emake -C lib/colorhug
		emake -C lib/compat
	fi
}

multilib_src_test() {
	if multilib_is_native_abi; then
		default
	else
		emake -C lib/colord check
		use gusb && emake -C lib/colorhug check
		emake -C lib/compat check
	fi
}

multilib_src_install() {
	if multilib_is_native_abi; then
		gnome2_src_install
	else
		gnome2_src_install -j1 -C lib/colord
		use gusb && gnome2_src_install -j1 -C lib/colorhug
		gnome2_src_install -j1 -C lib/compat
		gnome2_src_install -j1 -C contrib/session-helper install-libcolord_includeHEADERS
	fi
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
