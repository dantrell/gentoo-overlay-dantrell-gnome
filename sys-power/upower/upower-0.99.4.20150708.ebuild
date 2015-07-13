# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit autotools eutils git-2 systemd

DESCRIPTION="D-Bus abstraction for enumerating power devices and querying history and statistics"
HOMEPAGE="http://upower.freedesktop.org/"
EGIT_REPO_URI="git://anongit.freedesktop.org/upower"
EGIT_COMMIT="305f62adf052aa972523d083ca44d3050f659ec9"

LICENSE="GPL-2"
SLOT="0/3" # based on SONAME of libupower-glib.so
KEYWORDS="-*"
IUSE="doc +deprecated +introspection ios kernel_FreeBSD kernel_linux"

RDEPEND=">=dev-libs/dbus-glib-0.100
	>=dev-libs/glib-2.40
	dev-util/gdbus-codegen
	sys-apps/dbus:=
	>=sys-auth/polkit-0.110
	introspection? ( dev-libs/gobject-introspection )
	kernel_linux? (
		virtual/libusb:1
		virtual/libgudev:=
		virtual/udev
		ios? (
			>=app-pda/libimobiledevice-1:=
			>=app-pda/libplist-1:=
			)
		)
	deprecated? ( >=sys-power/pm-utils-1.4.1-r2 )
	doc? ( dev-util/gtk-doc )"
DEPEND="${RDEPEND}
	dev-libs/gobject-introspection-common
	dev-libs/libxslt
	app-text/docbook-xsl-stylesheets
	dev-util/intltool
	virtual/pkgconfig"

QA_MULTILIB_PATHS="usr/lib/${PN}/.*"

DOCS="AUTHORS HACKING NEWS README"

src_prepare() {
	if use deprecated; then
		# From Funtoo:
		# 	https://bugs.funtoo.org/browse/FL-1329
		epatch "${FILESDIR}"/${PN}-0.99.2-restore-deprecated-code.patch

		# From Debian:
		#	https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718458
		#	https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718491
		epatch "${FILESDIR}"/${PN}-0.99.0-always-use-pm-utils-backend.patch
	fi

	eautoreconf
}

src_configure() {
	local backend

	if use kernel_linux; then
		backend=linux
	elif use kernel_FreeBSD; then
		backend=freebsd
	else
		backend=dummy
	fi

	econf \
		--libexecdir="${EPREFIX}"/usr/lib/${PN} \
		--localstatedir="${EPREFIX}"/var \
		--disable-static \
		--enable-man-pages \
		--disable-tests \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--with-backend=${backend} \
		$(use_enable deprecated) \
		$(use_enable doc gtk-doc) \
		$(use_enable doc gtk-doc-html) \
		$(use_enable introspection) \
		$(use_with ios idevice) \
		"$(systemd_with_utildir)" \
		"$(systemd_with_unitdir)"
}

src_install() {
	default

	if use doc; then
		# http://bugs.gentoo.org/487400
		insinto /usr/share/doc/${PF}/html/UPower
		doins doc/html/*
		dosym /usr/share/doc/${PF}/html/UPower /usr/share/gtk-doc/html/UPower
	fi

	keepdir /var/lib/upower #383091
	prune_libtool_files
}
