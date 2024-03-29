# Distributed under the terms of the GNU General Public License v2

EAPI="7"

GCONF_DEBUG="no"
VALA_USE_DEPEND="vapigen"

inherit autotools desktop eutils readme.gentoo-r1 vala xdg-utils

DESCRIPTION="Set of GObject and Gtk objects for connecting to Spice servers and a client GUI"
HOMEPAGE="https://www.spice-space.org https://cgit.freedesktop.org/spice/spice-gtk/"
SRC_URI="https://www.spice-space.org/download/gtk/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="dbus gstaudio gstvideo +gtk3 +introspection lz4 mjpeg policykit pulseaudio sasl smartcard static-libs usbredir vala webdav"
REQUIRED_USE="?? ( pulseaudio gstaudio )"

# TODO:
# * check if sys-freebsd/freebsd-lib (from virtual/acl) provides acl/libacl.h
# * use external pnp.ids as soon as that means not pulling in gnome-desktop
RDEPEND="
	dev-libs/openssl:0=
	pulseaudio? ( media-sound/pulseaudio[glib] )
	gstvideo? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
		media-libs/gst-plugins-good:1.0
		)
	gstaudio? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
		media-libs/gst-plugins-good:1.0
		)
	>=x11-libs/pixman-0.17.7
	media-libs/opus
	gtk3? ( x11-libs/gtk+:3[introspection?] )
	>=dev-libs/glib-2.42:2
	>=x11-libs/cairo-1.2
	media-libs/libjpeg-turbo:0=
	sys-libs/zlib
	introspection? ( dev-libs/gobject-introspection:= )
	lz4? ( app-arch/lz4 )
	sasl? ( dev-libs/cyrus-sasl )
	smartcard? ( app-emulation/qemu[smartcard] )
	usbredir? (
		sys-apps/hwdata
		>=sys-apps/usbredir-0.4.2
		virtual/libusb:1
		dev-libs/libgudev:=
		policykit? (
			sys-apps/acl
			>=sys-auth/polkit-0.110-r1
			!~sys-auth/polkit-0.111 )
		)
	webdav? (
		net-libs/phodav:2.0
		>=net-libs/libsoup-2.49.91:2.4 )
"
DEPEND="${RDEPEND}
	>=app-emulation/spice-protocol-0.12.14
	<app-emulation/spice-protocol-14.0
	dev-perl/Text-CSV
	>=dev-build/gtk-doc-am-1.14
	>=dev-util/intltool-0.40.0
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.34-openssl11.patch
)

src_prepare() {
	# bug 558558
	export GIT_CEILING_DIRECTORIES="${WORKDIR}"
	echo GIT_CEILING_DIRECTORIES=${GIT_CEILING_DIRECTORIES}

	default

	# Lower the minimum required GLib version
	sed -i configure.ac \
		-e 's/2\.46/2\.42/' || die
	sed -i configure.ac \
		-e 's/2_46/2_42/' || die

	eautoreconf

	use vala && vala_src_prepare
}

src_configure() {
	# Prevent sandbox violations, bug #581836
	# https://bugzilla.gnome.org/show_bug.cgi?id=744134
	# https://bugzilla.gnome.org/show_bug.cgi?id=744135
	addpredict /dev

	# Clean up environment, bug #586642
	xdg_environment_reset

	local myconf

	if use vala ; then
		# force vala regen for MinGW, etc
		rm -fv gtk/controller/controller.{c,vala.stamp} gtk/controller/menu.c
	fi

	myconf="
		$(use_enable dbus)
		$(use_with gtk3 gtk 3.0)
		$(use_enable introspection)
		$(use_enable mjpeg builtin-mjpeg)
		$(use_enable policykit polkit)
		$(use_enable pulseaudio pulse)
		$(use_enable gstaudio)
		$(use_enable gstvideo)
		$(use_with sasl)
		$(use_enable smartcard)
		$(use_enable static-libs static)
		$(use_enable usbredir)
		$(use_with usbredir usb-acl-helper-dir /usr/libexec)
		$(use_with usbredir usb-ids-path /usr/share/hwdata/usb.ids)
		$(use_enable vala)
		$(use_enable webdav)
		--disable-celt051
		--disable-gtk-doc
		--disable-maintainer-mode
		--disable-werror
		--enable-pie"

	econf ${myconf}
}

src_compile() {
	# Prevent sandbox violations, bug #581836
	# https://bugzilla.gnome.org/show_bug.cgi?id=744134
	# https://bugzilla.gnome.org/show_bug.cgi?id=744135
	addpredict /dev

	default
}

src_install() {
	default

	# Remove .la files if they're not needed
	use static-libs || find "${D}" -name '*.la' -delete || die

	make_desktop_entry spicy Spicy "utilities-terminal" "Network;RemoteAccess;"
	readme.gentoo_create_doc
}
