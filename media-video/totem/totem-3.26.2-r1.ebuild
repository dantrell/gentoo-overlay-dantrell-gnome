# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_6,3_7,3_8} )
PYTHON_REQ_USE="threads(+)"

inherit gnome2 meson vala python-single-r1

DESCRIPTION="Media player for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Videos"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE="cdr doc +introspection lirc nautilus +python test +vala vanilla-thumbnailer"
# see bug #359379
REQUIRED_USE="
	python? ( introspection ${PYTHON_REQUIRED_USE} )
	vala? ( introspection )
"

RESTRICT="!test? ( test )"

# FIXME:
# Runtime dependency on gnome-session-2.91
COMMON_DEPEND="
	>=dev-libs/glib-2.35:2[dbus]
	>=x11-libs/gtk+-3.19.4:3[introspection?]
	>=media-libs/gstreamer-1.6.0:1.0
	>=media-libs/gst-plugins-base-1.6.0:1.0[X,introspection?,pango]
	media-libs/gst-plugins-good:1.0
	>=media-libs/grilo-0.3.0:0.3[playlist]
	>=dev-libs/libpeas-1.1[gtk]
	>=dev-libs/totem-pl-parser-3.26.0:0=[introspection?]
	>=media-libs/clutter-1.17.3:1.0[gtk]
	>=media-libs/clutter-gst-2.99.2:3.0
	>=media-libs/clutter-gtk-1.8.1:1.0
	gnome-base/gnome-desktop:3=
	gnome-base/gsettings-desktop-schemas
	x11-libs/libX11
	>=x11-libs/cairo-1.14
	>=x11-libs/gdk-pixbuf-2.23.0:2
	introspection? ( >=dev-libs/gobject-introspection-0.6.7:= )

	cdr? ( >=dev-libs/libxml2-2.6:2 )
	lirc? ( app-misc/lirc )
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
	doc? ( >=dev-util/gtk-doc-1.14 )
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	x11-base/xorg-proto
	vala? ( $(vala_depend) )
"
# perl for pod2man
# docbook-xml-dtd is needed for user doc
# Prevent dev-python/pylint dep, bug #482538

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

	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	for card in /dev/dri/card* ; do
		addpredict "${card}"
	done

	for render in /dev/dri/render* ; do
		addpredict "${render}"
	done

	# Disabled: sample-python, sample-vala, zeitgeist-dp
	# brasero-disc-recorder and gromit require gtk+[X], but totem itself does
	# for now still too, so no point in optionality based on that yet.
	local plugins="apple-trailers,autoload-subtitles"
	plugins+=",im-status,gromit,media-player-keys,ontop"
	plugins+=",properties,recent,screensaver,screenshot"
	plugins+=",skipto,variable-rate,vimeo"
	use cdr && plugins+=",brasero-disc-recorder"
	use lirc && plugins+=",lirc"
	use nautilus && plugins+=",save-file"
	use python && plugins+=",dbusservice,pythonconsole,opensubtitles"
	use vala && plugins+=",rotation"

	local emesonargs=(
		-D enable-easy-codec-installation=yes
		-D enable-python=$(usex python yes no)
		-D enable-vala=$(usex vala yes no)
		-D with-plugins=auto
		-D enable-nautilus=$(usex nautilus yes no)
		-D enable-gtk-doc=$(usex doc true false)
		-D enable-introspection=$(usex introspection yes no)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	if use python ; then
		python_optimize "${ED}"usr/$(get_libdir)/totem/plugins/
	fi
}
