# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_6,3_7,3_8} )
PYTHON_REQ_USE="threads(+)"

inherit gnome.org gnome2-utils meson xdg python-single-r1

DESCRIPTION="Media player for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Videos"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk-doc nautilus +python test vanilla-thumbnailer"
# see bug #359379
REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
"

RESTRICT="!test? ( test )"

# FIXME:
# Runtime dependency on gnome-session-2.91
COMMON_DEPEND="
	>=dev-libs/glib-2.43.4:2
	>=x11-libs/gtk+-3.19.4:3[X,introspection]
	>=media-libs/gstreamer-1.6.0:1.0
	>=media-libs/gst-plugins-base-1.6.0:1.0[X,pango]
	>=media-libs/gst-plugins-good-1.6.0:1.0
	>=media-libs/grilo-0.3.0:0.3[playlist]
	>=dev-libs/libpeas-1.1.0[gtk]
	>=dev-libs/totem-pl-parser-3.10.1:0=[introspection]
	>=media-libs/clutter-1.17.3:1.0[gtk]
	>=media-libs/clutter-gst-2.99.2:3.0
	>=media-libs/clutter-gtk-1.8.1:1.0
	gnome-base/gnome-desktop:3=
	gnome-base/gsettings-desktop-schemas
	x11-libs/libX11
	>=x11-libs/cairo-1.14
	x11-libs/gdk-pixbuf:2
	>=dev-libs/gobject-introspection-1.54:=

	nautilus? ( >=gnome-base/nautilus-2.91.3 )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-python/pygobject-2.90.3:3[${PYTHON_MULTI_USEDEP}]
		')
	)
"
RDEPEND="${COMMON_DEPEND}
	media-plugins/grilo-plugins:0.3
	media-plugins/gst-plugins-meta:1.0
	media-plugins/gst-plugins-taglib:1.0
	x11-themes/adwaita-icon-theme
	python? (
		>=dev-libs/libpeas-1.1.0[python,${PYTHON_SINGLE_USEDEP}]
		$(python_gen_cond_dep '
			dev-python/dbus-python[${PYTHON_MULTI_USEDEP}]
		')
	)
"
DEPEND="${COMMON_DEPEND}
	dev-lang/perl
	app-text/docbook-xml-dtd:4.5
	gtk-doc? ( >=dev-util/gtk-doc-1.14 )
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	x11-base/xorg-proto
"
# perl for pod2man
# docbook-xml-dtd is needed for user doc
# Prevent dev-python/pylint dep, bug #482538

PATCHES=(
	"${FILESDIR}"/${PN}-3.34.0-control-plugins.patch # Do not force all plugins
	"${FILESDIR}"/${PN}-3.34.0-gst-inspect-sandbox.patch # Allow disabling calls to gst-inspect (sandbox issue)
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	# Support the FFMPEG Thumbnailer out-of-the-box
	if ! use vanilla-thumbnailer; then
		sed -e "s/totem-video-thumbnailer/ffmpegthumbnailer/" \
			-e "s/-s %s %u %o/-i %i -o %o -s %s -c png -f/" \
			-i data/totem.thumbnailer.in
	fi

	xdg_src_prepare
}

src_configure() {
	# Prevent sandbox violations when we need write access to
	# /dev/dri/card* in its init phase, bug #358755
	for card in /dev/dri/card* ; do
		addpredict "${card}"
	done

	# Prevent sandbox violations when we need write access to
	# /dev/dri/render* in its init phase, bug #358755
	for render in /dev/dri/render* ; do
		addpredict "${render}"
	done

	# Disabled: sample-python, zeitgeist-dp
	# brasero-disc-recorder and gromit require gtk+[X], but totem itself does
	# for now still too, so no point in optionality based on that yet.
	local plugins="apple-trailers,autoload-subtitles,open-directory"
	plugins+=",im-status,media-player-keys"
	plugins+=",properties,recent,screensaver,screenshot"
	plugins+=",skipto,variable-rate,vimeo,rotation"
	use nautilus && plugins+=",save-file"
	use python && plugins+=",dbusservice,pythonconsole,opensubtitles"

	local emesonargs=(
		-Denable-easy-codec-installation=yes
		-Denable-python=$(usex python yes no)
		-Dwith-plugins=${plugins}
		$(meson_use gtk-doc enable-gtk-doc)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	if use python ; then
		python_optimize "${ED}"usr/$(get_libdir)/totem/plugins/
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_icon_cache_update
	gnome2_schemas_update
}
