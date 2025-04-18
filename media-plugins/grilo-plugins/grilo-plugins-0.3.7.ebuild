# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome2 python-any-r1

DESCRIPTION="A framework for easy media discovery and browsing"
HOMEPAGE="https://wiki.gnome.org/Projects/Grilo"

LICENSE="LGPL-2.1+"
SLOT="0.3"
KEYWORDS="*"

IUSE="daap dvd examples chromaprint flickr freebox gnome-online-accounts lua subtitles test thetvdb tracker upnp-av vimeo +youtube"

RESTRICT="!test? ( test )"

# Bump gom requirement to avoid segfaults
RDEPEND="
	>=dev-libs/glib-2.44:2
	>=media-libs/grilo-0.3.6:${SLOT}=[network,playlist]
	media-libs/libmediaart:2.0
	>=dev-libs/gom-0.3.2

	dev-libs/gmime:3.0
	dev-libs/json-glib
	dev-libs/libxml2:2
	dev-db/sqlite:3

	chromaprint? ( media-plugins/gst-plugins-chromaprint:1.0 )
	daap? ( >=net-libs/libdmapsharing-2.9.12:3.0 )
	dvd? ( >=dev-libs/totem-pl-parser-3.4.1 )
	flickr? ( net-libs/liboauth )
	freebox? ( net-dns/avahi[dbus] )
	gnome-online-accounts? ( >=net-libs/gnome-online-accounts-3.17.91:= )
	lua? (
		>=dev-lang/lua-5.3
		app-arch/libarchive
		dev-libs/libxml2:2
		>=dev-libs/totem-pl-parser-3.4.1 )
	subtitles? ( net-libs/libsoup:2.4 )
	thetvdb? (
		app-arch/libarchive
		dev-libs/libxml2 )
	tracker? ( >=app-misc/tracker-0.10.5:0= )
	youtube? (
		>=dev-libs/libgdata-0.9.1:=
		>=dev-libs/totem-pl-parser-3.4.1 )
	upnp-av? (
		net-libs/libsoup:2.4
		net-libs/dleyna-connector-dbus
		net-misc/dleyna-server )
	vimeo? (
		>=dev-libs/totem-pl-parser-3.4.1 )

	!media-plugins/grilo-plugins:0.2
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.5
	app-text/yelp-tools
	>=dev-util/gdbus-codegen-2.44
	>=dev-util/intltool-0.40.0
	virtual/pkgconfig
	lua? ( dev-util/gperf )
	upnp-av? ( test? (
		${PYTHON_DEPS}
		$(python_gen_any_dep 'dev-python/python-dbusmock[${PYTHON_USEDEP}]') ) )
"

python_check_deps() {
	use upnp-av && use test && python_has_version -d "dev-python/python-dbusmock[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use upnp-av && use test && python-any-r1_pkg_setup
}

src_prepare () {
	gnome2_src_prepare
	sed -e "s:GETTEXT_PACKAGE=grilo-plugins$:GETTEXT_PACKAGE=grilo-plugins-${SLOT}:" \
		-i configure.ac configure || die "sed configure.ac configure failed"
}

src_configure() {
	# --enable-debug only changes CFLAGS, useless for us
	# --enable-shoutcast seems to be broken
	gnome2_src_configure \
		--disable-static \
		--disable-debug \
		--disable-uninstalled \
		--enable-bookmarks \
		--enable-filesystem \
		--enable-gravatar \
		--enable-jamendo \
		--enable-local-metadata \
		--enable-magnatune \
		--enable-metadata-store \
		--enable-podcasts \
		--enable-raitv \
		--disable-shoutcast \
		--enable-tmdb \
		$(use_enable chromaprint) \
		$(use_enable daap dmap) \
		$(use_enable dvd optical-media) \
		$(use_enable flickr) \
		$(use_enable freebox) \
		$(use_enable gnome-online-accounts goa) \
		$(use_enable lua lua-factory) \
		$(use_enable subtitles opensubtitles) \
		$(use_enable thetvdb) \
		$(use_enable tracker) \
		$(use_enable upnp-av dleyna) \
		$(use_enable vimeo) \
		$(use_enable youtube)
}

src_install() {
	if use examples; then
		docinto examples
		doins help/examples/*.c
	fi

	gnome2_src_install \
		DOC_MODULE_VERSION=${SLOT%/*} \
		HELP_ID="grilo-plugins-${SLOT%/*}" \
		HELP_MEDIA=""

	mv "${ED}"/usr/share/help/C/grilo-plugins{,-0.3} || die
}
