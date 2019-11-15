# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_5,3_6,3_7} )

inherit autotools bash-completion-r1 gnome2 linux-info python-any-r1 vala versionator virtualx

DESCRIPTION="A tagging metadata database, search tool and indexer"
HOMEPAGE="https://wiki.gnome.org/Projects/Tracker"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0/100"
KEYWORDS="*"

IUSE="cue elibc_glibc exif ffmpeg flac gif gsf
gstreamer gtk iptc +iso +jpeg libav +miner-fs mp3 networkmanager
pdf playlist rss +seccomp stemmer test +tiff upnp-av upower +vorbis +xml xmp xps"
REQUIRED_USE="
	?? ( gstreamer ffmpeg )
	cue? ( gstreamer )
	upnp-av? ( gstreamer )
	!miner-fs? ( !cue !exif !flac !gif !gsf !iptc !iso !jpeg !mp3 !pdf !playlist !tiff !vorbis !xml !xmp !xps )
"

# According to NEWS, introspection is non-optional
# glibc-2.12 needed for SCHED_IDLE (see bug #385003)
# sqlite-3.9.0 for FTS5 support
# seccomp is automagic, though we want to use it whenever possible (linux)
RDEPEND="
	>=app-i18n/enca-1.9
	>=dev-db/sqlite-3.9.0:=
	>=dev-libs/glib-2.44:2
	>=dev-libs/gobject-introspection-0.9.5:=
	>=dev-libs/icu-4.8.1.1:=
	>=dev-libs/json-glib-1.0
	>=media-libs/libpng-1.2:0=
	>=net-libs/libsoup-2.40:2.4
	>=x11-libs/pango-1:=
	sys-apps/util-linux
	virtual/imagemagick-tools[png,jpeg?]

	cue? ( media-libs/libcue:= )
	elibc_glibc? ( >=sys-libs/glibc-2.12 )
	exif? ( >=media-libs/libexif-0.6 )
	ffmpeg? (
		libav? ( media-video/libav:= )
		!libav? ( media-video/ffmpeg:0= )
	)
	flac? ( >=media-libs/flac-1.2.1 )
	gif? ( media-libs/giflib:= )
	gsf? ( >=gnome-extra/libgsf-1.14.24:0= )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0 )
	gtk? (
		>=x11-libs/gtk+-3:3 )
	iptc? ( media-libs/libiptcdata )
	iso? ( >=sys-libs/libosinfo-0.2.9:= )
	jpeg? ( virtual/jpeg:0 )
	upower? ( >=sys-power/upower-0.9:= )
	mp3? ( >=media-libs/taglib-1.6 )
	networkmanager? ( >=net-misc/networkmanager-0.8:= )
	pdf? (
		>=x11-libs/cairo-1:=
		>=app-text/poppler-0.16:=[cairo,utils]
		>=x11-libs/gtk+-2.12:2 )
	playlist? ( >=dev-libs/totem-pl-parser-3:= )
	rss? ( >=net-libs/libgrss-0.7:0 )
	stemmer? ( dev-libs/snowball-stemmer )
	tiff? ( media-libs/tiff:0 )
	upnp-av? ( >=media-libs/gupnp-dlna-0.9.4:2.0 )
	vorbis? ( >=media-libs/libvorbis-0.22 )
	xml? ( >=dev-libs/libxml2-2.6 )
	xmp? ( >=media-libs/exempi-2.1:2 )
	xps? ( app-text/libgxps )
	!gstreamer? ( !ffmpeg? ( || ( media-video/totem media-video/mplayer ) ) )
	seccomp? ( >=sys-libs/libseccomp-2.0 )
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	$(vala_depend)
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.8
	>=dev-util/intltool-0.40.0
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	test? (
		>=dev-libs/dbus-glib-0.82-r1
		>=sys-apps/dbus-1.3.1[X] )
"
PDEPEND=""

function inotify_enabled() {
	if linux_config_exists; then
		if ! linux_chkconfig_present INOTIFY_USER; then
			ewarn "You should enable the INOTIFY support in your kernel."
			ewarn "Check the 'Inotify support for userland' under the 'File systems'"
			ewarn "option. It is marked as CONFIG_INOTIFY_USER in the config"
			die 'missing CONFIG_INOTIFY'
		fi
	else
		einfo "Could not check for INOTIFY support in your kernel."
	fi
}

pkg_setup() {
	linux-info_pkg_setup
	inotify_enabled

	python-any-r1_pkg_setup
}

src_prepare() {
	eautoreconf # See bug #367975
	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local myconf=""

	if use gstreamer ; then
		myconf="${myconf} --enable-generic-media-extractor=gstreamer"
		if use upnp-av; then
			myconf="${myconf} --with-gstreamer-backend=gupnp-dlna"
		else
			myconf="${myconf} --with-gstreamer-backend=discoverer"
		fi
	elif use ffmpeg ; then
		myconf="${myconf} --enable-generic-media-extractor=libav"
	else
		myconf="${myconf} --enable-generic-media-extractor=external"
	fi

	# unicode-support: libunistring, libicu or glib ?
	# According to NEWS, introspection is required
	# is not being generated
	gnome2_src_configure \
		--disable-hal \
		--disable-miner-evolution \
		--disable-static \
		--enable-abiword \
		--enable-artwork \
		--enable-dvi \
		--enable-enca \
		--enable-guarantee-metadata \
		--enable-icon \
		--enable-introspection \
		--disable-libmediaart \
		--enable-libpng \
		--enable-miner-apps \
		--enable-miner-user-guides \
		--enable-ps \
		--enable-text \
		--enable-tracker-fts \
		--enable-tracker-writeback \
		--with-unicode-support=libicu \
		--with-bash-completion-dir="$(get_bashcompdir)" \
		$(use_enable cue libcue) \
		$(use_enable exif libexif) \
		$(use_enable flac libflac) \
		$(use_enable gif libgif) \
		$(use_enable gsf libgsf) \
		$(use_enable gtk tracker-needle) \
		$(use_enable gtk tracker-preferences) \
		$(use_enable iptc libiptcdata) \
		$(use_enable iso libosinfo) \
		$(use_enable jpeg libjpeg) \
		$(use_enable upower upower) \
		$(use_enable miner-fs) \
		$(use_enable mp3 taglib) \
		$(use_enable mp3) \
		$(use_enable networkmanager network-manager) \
		$(use_enable pdf poppler) \
		$(use_enable playlist) \
		$(use_enable rss miner-rss) \
		$(use_enable stemmer libstemmer) \
		$(use_enable test functional-tests) \
		$(use_enable test unit-tests) \
		$(use_enable tiff libtiff) \
		$(use_enable vorbis libvorbis) \
		$(use_enable xml libxml2) \
		$(use_enable xmp exempi) \
		$(use_enable xps libgxps) \
		${myconf}
}

src_test() {
	# G_MESSAGES_DEBUG, upstream bug #699401#c1
	virtx emake check TESTS_ENVIRONMENT="dbus-run-session" G_MESSAGES_DEBUG="all"
}
