# Distributed under the terms of the GNU General Public License v2

EAPI="7"

GCONF_DEBUG="no"
VALA_USE_DEPEND="vapigen"

inherit autotools desktop readme.gentoo-r1 vala xdg-utils

DESCRIPTION="Set of GObject and Gtk objects for connecting to Spice servers and a client GUI"
HOMEPAGE="https://www.spice-space.org https://cgit.freedesktop.org/spice/spice-gtk/"
SRC_URI="https://www.spice-space.org/download/gtk/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="+gtk3 +introspection lz4 mjpeg policykit pulseaudio sasl smartcard static-libs usbredir vala webdav"

# TODO:
# * check if sys-freebsd/freebsd-lib (from virtual/acl) provides acl/libacl.h
# * use external pnp.ids as soon as that means not pulling in gnome-desktop
RDEPEND="
	>=dev-libs/glib-2.46:2
	dev-libs/json-glib:0=
	media-libs/gst-plugins-base:1.0
	media-libs/gst-plugins-good:1.0
	media-libs/gstreamer:1.0[introspection?]
	media-libs/opus
	sys-libs/zlib
	media-libs/libjpeg-turbo:0=
	>=x11-libs/cairo-1.2
	>=x11-libs/pixman-0.17.7
	gtk3? ( >=x11-libs/gtk+-3.22:3[introspection?] )
	introspection? ( dev-libs/gobject-introspection:= )
	dev-libs/openssl:0=
	lz4? ( app-arch/lz4 )
	pulseaudio? ( media-sound/pulseaudio[glib] )
	sasl? ( dev-libs/cyrus-sasl )
	smartcard? ( app-emulation/qemu[smartcard] )
	usbredir? (
		sys-apps/hwdata
		>=sys-apps/usbredir-0.4.2
		virtual/libusb:1
		policykit? (
			sys-apps/acl
			>=sys-auth/polkit-0.110-r1
		)
	)
	webdav? (
		net-libs/phodav:2.0
		>=net-libs/libsoup-2.49.91:2.4 )
"
# TODO: spice-gtk has an automagic dependency on media-libs/libva without a
# configure knob. The package is relatively lightweight so we just depend
# on it unconditionally for now. It would be cleaner to transform this into
# a USE="vaapi" conditional and patch the buildsystem...
RDEPEND="${RDEPEND}
	amd64? ( media-libs/libva:= )
	arm64? ( media-libs/libva:= )
	x86? ( media-libs/libva:= )
"
DEPEND="${RDEPEND}
	>=app-emulation/spice-protocol-0.14.0
	dev-perl/Text-CSV
	>=dev-build/gtk-doc-am-1.14
	>=dev-util/intltool-0.40.0
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.37-adjust-to-window-scaling.patch
)

src_prepare() {
	# bug 558558
	export GIT_CEILING_DIRECTORIES="${WORKDIR}"

	default

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
	myconf="
		$(use_with gtk3 gtk 3.0)
		$(use_enable introspection)
		$(use_enable mjpeg builtin-mjpeg)
		$(use_enable policykit polkit)
		$(use_enable pulseaudio pulse)
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
