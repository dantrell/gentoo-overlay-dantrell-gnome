# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"
VALA_MIN_API_VERSION="0.22"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala virtualx

DESCRIPTION="Library for aggregating people from multiple sources"
HOMEPAGE="https://wiki.gnome.org/Projects/Folks"

LICENSE="LGPL-2.1+"
SLOT="0/25" # subslot = libfolks soname version
KEYWORDS="*"

# TODO: --enable-profiling
# Vala isn't really optional, https://bugzilla.gnome.org/show_bug.cgi?id=701099
IUSE="bluetooth eds +telepathy test tracker utils zeitgeist"
REQUIRED_USE="bluetooth? ( eds )"

COMMON_DEPEND="
	$(vala_depend)
	>=dev-libs/glib-2.38.2:2
	dev-libs/dbus-glib
	>=dev-libs/gobject-introspection-1.30:=
	>=dev-libs/libgee-0.10:0.8[introspection]
	dev-libs/libxml2
	sys-libs/ncurses:0=
	sys-libs/readline:0=

	bluetooth? ( >=net-wireless/bluez-5 )
	eds? ( >=gnome-extra/evolution-data-server-3.13.90:=[vala] )
	telepathy? ( >=net-libs/telepathy-glib-0.19[vala] )
	tracker? ( >=app-misc/tracker-1:0= )
	zeitgeist? ( >=gnome-extra/zeitgeist-0.9.14 )
"
# telepathy-mission-control needed at runtime; it is used by the telepathy
# backend via telepathy-glib's AccountManager binding.
RDEPEND="${COMMON_DEPEND}
	net-im/telepathy-mission-control
"
# folks socialweb backend requires that libsocialweb be built with USE=vala,
# even when building folks with --disable-vala.
#
# FIXME:
# test? ( bluetooth? ( dbusmock is missing in the tree ) )
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.50.0
	sys-devel/gettext
	virtual/pkgconfig

	test? (
		sys-apps/dbus
		bluetooth? (
			>=gnome-extra/evolution-data-server-3.9.1
			>=dev-libs/glib-2.39.2:2 ) )
	!<dev-lang/vala-0.22.1:0.22
"

src_prepare() {
	# From GNOME
	# 	https://git.gnome.org/browse/folks/commit/?id=baa67c2bd6f07180921fd917f9aecc1e2082ac17
	# 	https://git.gnome.org/browse/folks/commit/?id=ef70ba956a1acb07a26928a52bd5def466102733
	epatch "${FILESDIR}"/${PN}-0.10.1-eds-update-to-new-eds-address-book-timeout-api.patch
	epatch "${FILESDIR}"/${PN}-0.10.1-build-drop-outdated-bluez-conditional-dependency-checks.patch

	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	# Rebuilding docs needs valadoc, which has no release
	gnome2_src_configure \
		$(use_enable bluetooth bluez-backend) \
		$(use_enable eds eds-backend) \
		$(use_enable eds ofono-backend) \
		$(use_enable telepathy telepathy-backend) \
		$(use_enable tracker tracker-backend) \
		$(use_enable utils inspect-tool) \
		$(use_enable test tests) \
		$(use_enable zeitgeist) \
		--enable-vala \
		--enable-import-tool \
		--disable-docs \
		--disable-fatal-warnings \
		--disable-libsocialweb-backend
}

src_test() {
	dbus-launch Xemake check
}
