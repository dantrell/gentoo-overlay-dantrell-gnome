# Distributed under the terms of the GNU General Public License v2

EAPI="6"

# PackageKit supports 3.2+, but entropy and portage backends are untested
PYTHON_COMPAT=( python2_7 )
VALA_USE_DEPEND="vapigen"

inherit autotools bash-completion-r1 multilib nsplugins python-single-r1 systemd vala xdg-utils

MY_PN="PackageKit"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Manage packages in a secure way using a cross-distro and cross-architecture API"
HOMEPAGE="https://www.freedesktop.org/software/PackageKit/"
SRC_URI="https://www.freedesktop.org/software/${MY_PN}/releases/${MY_P}.tar.xz"

LICENSE="GPL-2"
SLOT="0/18"
KEYWORDS="*"

IUSE="ck connman consolekit cron command-not-found elogind +introspection networkmanager nsplugin entropy systemd test vala"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	?? ( ck consolekit elogind systemd )
	vala? ( introspection )
	entropy? ( $(python_gen_useflags 'python2*' ) )
"

RESTRICT="test"

# While not strictly needed, consolekit or elogind
# is the alternative to systemd-login to get current session's user.
COMMON_DEPEND="
	>=app-shells/bash-completion-2
	dev-db/sqlite:3
	>=dev-libs/dbus-glib-0.74
	>=dev-libs/glib-2.32.0:2
	>=sys-auth/polkit-0.98
	>=sys-apps/dbus-1.3.0
	${PYTHON_DEPS}
	ck? ( <sys-auth/consolekit-0.9 )
	connman? ( net-misc/connman )
	consolekit? ( >=sys-auth/consolekit-0.9 )
	elogind? ( sys-auth/elogind )
	introspection? ( >=dev-libs/gobject-introspection-0.9.9:= )
	networkmanager? ( >=net-misc/networkmanager-0.6.4:= )
	nsplugin? (
		>=dev-libs/nspr-4.8
		x11-libs/cairo
		>=x11-libs/gtk+-2.14.0:2
		x11-libs/pango
	)
	systemd? ( >=sys-apps/systemd-204 )
"
# vala-common needed for eautoreconf
DEPEND="${COMMON_DEPEND}
	dev-libs/libxslt[${PYTHON_USEDEP}]
	dev-libs/vala-common
	>=dev-util/gtk-doc-am-1.11
	>=dev-util/intltool-0.35.0
	sys-devel/autoconf-archive
	sys-devel/gettext
	virtual/pkgconfig
	nsplugin? ( >=net-misc/npapi-sdk-0.27 )
	vala? ( $(vala_depend) )
"
RDEPEND="${COMMON_DEPEND}
	>=app-portage/layman-2[${PYTHON_USEDEP}]
	|| (
		>=sys-apps/portage-2.2[${PYTHON_USEDEP}]
		sys-apps/portage-mgorny[${PYTHON_USEDEP}]
	)
	entropy? ( >=sys-apps/entropy-234[${PYTHON_USEDEP}] )
"

PATCHES=(
	# Fixes QA Notices:
	# - https://github.com/gentoo/gentoo/pull/1760
	# - https://github.com/hughsie/PackageKit/issues/143
	"${FILESDIR}"/${PN}-1.1.1-cache-qafix.patch

	# Adds elogind support:
	# - https://bugs.gentoo.org/620948
	"${FILESDIR}"/${PN}-1.0.11-support-elogind.patch
)

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	eautoreconf
	use vala && vala_src_prepare
}

src_configure() {
	xdg_environment_reset
	econf \
		--disable-gstreamer-plugin \
		--disable-gtk-doc \
		--disable-gtk-module \
		--disable-schemas-compile \
		--disable-static \
		--enable-bash-completion \
		--enable-man-pages \
		--enable-nls \
		--enable-portage \
		--localstatedir=/var \
		$(use_enable command-not-found) \
		$(use_enable connman) \
		$(use_enable cron) \
		$(use_enable elogind) \
		$(use_enable entropy) \
		$(use_enable introspection) \
		$(use_enable networkmanager) \
		$(use_enable nsplugin browser-plugin) \
		$(use_enable systemd) \
		$(use_enable test daemon-tests) \
		$(use_enable test local) \
		$(use_enable vala) \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
}

src_install() {
	emake DESTDIR="${D}" install
	prune_libtool_files --all

	if use nsplugin; then
		dodir "/usr/$(get_libdir)/${PLUGINS_DIR}"
		mv "${D}/usr/$(get_libdir)/mozilla/plugins"/* \
			"${D}/usr/$(get_libdir)/${PLUGINS_DIR}/" || die
	fi
}
