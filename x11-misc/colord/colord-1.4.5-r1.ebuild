# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit bash-completion-r1 meson-multilib vala

DESCRIPTION="System service to accurately color manage input and output devices"
HOMEPAGE="https://www.freedesktop.org/software/colord/"
SRC_URI="https://www.freedesktop.org/software/colord/releases/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0/2" # subslot = libcolord soname version
KEYWORDS="*"

IUSE="gtk-doc argyllcms examples extra-print-profiles +introspection scanner systemd test +udev vala"
REQUIRED_USE="
	scanner? ( udev )
	vala? ( introspection )
"

RESTRICT="!test? ( test ) test" # Tests try to read and write files in /tmp

DEPEND="
	>=dev-libs/glib-2.58.0:2[${MULTILIB_USEDEP}]
	>=media-libs/lcms-2.6:2=[${MULTILIB_USEDEP}]
	dev-db/sqlite:3=[${MULTILIB_USEDEP}]
	>=dev-libs/libgusb-0.2.7[introspection?,${MULTILIB_USEDEP}]
	udev? (
		dev-libs/libgudev:=[${MULTILIB_USEDEP}]
		virtual/libudev:=[${MULTILIB_USEDEP}]
		virtual/udev
	)
	systemd? ( >=sys-apps/systemd-44:0= )
	scanner? (
		media-gfx/sane-backends
		sys-apps/dbus
	)
	>=sys-auth/polkit-0.104
	argyllcms? ( media-gfx/argyllcms )
	introspection? ( >=dev-libs/gobject-introspection-0.9.8:= )
"
RDEPEND="${DEPEND}
	acct-group/colord
	acct-user/colord
"
BDEPEND="
	acct-group/colord
	acct-user/colord
	app-text/docbook-xsl-ns-stylesheets
	dev-libs/libxslt
	>=dev-util/intltool-0.35
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	extra-print-profiles? ( media-gfx/argyllcms )
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.4.5-tests-Don-t-use-exact-floating-point-comparisons.patch
	"${FILESDIR}"/${PN}-1.4.5-optional-introspection.patch
)

src_prepare() {
	default
	use vala && vala_src_prepare

	# Test requires a running session
	# https://github.com/hughsie/colord/issues/94
	sed -i -e "/test('colord-test-daemon'/d" lib/colord/meson.build || die

	# Adapt to Gentoo paths
	sed -i \
		-e "s|find_program('spotread'|find_program('argyll-spotread'|" \
		-e "s|find_program('colprof'|find_program('argyll-colprof'|" \
		meson.build || die

	# meson gnome.generate_vapi properly handles VAPIGEN and other vala
	# environment variables. It is counter-productive to check for an
	# unversioned vapigen, as that breaks versioned VAPIGEN usages.
	sed -i -e "/find_program('vapigen')/d" meson.build || die
}

multilib_src_configure() {
	local emesonargs=(
		$(meson_native_true daemon)
		-Dbash_completion=false
		$(meson_use udev udev_rules)
		$(meson_native_use_bool systemd)
		-Dlibcolordcompat=true
		$(meson_native_use_bool argyllcms argyllcms_sensor)
		-Dreverse=false
		$(meson_native_use_bool scanner sane)
		$(meson_native_use_bool introspection)
		$(meson_native_use_bool vala vapi)
		$(meson_native_use_bool extra-print-profiles print_profiles)
		$(meson_use test tests)
		-Dinstalled_tests=false
		-Ddaemon_user=colord
		-Dman=true
		$(meson_use gtk-doc docs)
		--localstatedir="${EPREFIX}"/var
	)
	meson_src_configure
}

multilib_src_install_all() {
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
