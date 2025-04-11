# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
VALA_USE_DEPEND="vapigen"

inherit autotools bash-completion-r1 multilib nsplugins python-single-r1 systemd vala xdg

MY_PN="PackageKit"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Manage packages in a secure way using a cross-distro and cross-architecture API"
HOMEPAGE="https://www.freedesktop.org/software/PackageKit/"
SRC_URI="https://www.freedesktop.org/software/${MY_PN}/releases/${MY_P}.tar.xz"

LICENSE="GPL-2"
SLOT="0/18"
KEYWORDS="*"

IUSE="ck command-not-found connman consolekit cron elogind +introspection networkmanager nsplugin systemd test vala"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	?? ( ck consolekit elogind systemd )
	vala? ( introspection )
"

RESTRICT="!test? ( test )"

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
	dev-libs/libxslt
	dev-libs/vala-common
	>=dev-build/gtk-doc-am-1.11
	>=dev-util/intltool-0.35.0
	dev-build/autoconf-archive
	sys-devel/gettext
	virtual/pkgconfig
	nsplugin? ( >=net-misc/npapi-sdk-0.27 )
	vala? ( $(vala_depend) )
"
RDEPEND="${COMMON_DEPEND}
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
	xdg_src_prepare

	eautoreconf
	use vala && vala_src_prepare
}

src_configure() {
	econf \
		--disable-gstreamer-plugin \
		--disable-gtk-doc \
		--disable-gtk-module \
		--disable-schemas-compile \
		--disable-static \
		--enable-bash-completion \
		--enable-man-pages \
		--enable-nls \
		--disable-portage \
		--localstatedir=/var \
		$(use_enable command-not-found) \
		$(use_enable connman) \
		$(use_enable cron) \
		$(use_enable elogind) \
		--disable-entropy \
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
	find "${D}" -name '*.la' -delete || die

	if use nsplugin; then
		dodir "/usr/$(get_libdir)/${PLUGINS_DIR}"
		mv "${D}/usr/$(get_libdir)/mozilla/plugins"/* \
			"${D}/usr/$(get_libdir)/${PLUGINS_DIR}/" || die
	fi
}
