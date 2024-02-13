# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools multilib-minimal xdg

DESCRIPTION="An implementation of the Interactice Connectivity Establishment standard (ICE)"
HOMEPAGE="https://nice.freedesktop.org/wiki/"
SRC_URI="https://nice.freedesktop.org/releases/${P}.tar.gz"

LICENSE="|| ( MPL-1.1 LGPL-2.1 )"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection +upnp"

RDEPEND="
	>=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
	upnp? ( >=net-libs/gupnp-igd-0.2.4:=[${MULTILIB_USEDEP}] )
"
DEPEND="${RDEPEND}
	dev-build/gtk-doc-am
	virtual/pkgconfig
"

src_prepare() {
	xdg_environment_reset

	# https://bugs.freedesktop.org/show_bug.cgi?id=90801
	eapply "${FILESDIR}"/${PN}-0.1.13-gstreamer.patch

	eapply_user

	eautoreconf
}

multilib_src_configure() {
	# gstreamer plugin split off into media-plugins/gst-plugins-libnice
	ECONF_SOURCE=${S} \
	econf \
		--disable-static \
		--disable-static-plugins \
		--without-gstreamer \
		--without-gstreamer-0.10 \
		$(multilib_native_use_enable introspection) \
		$(use_enable upnp gupnp)

	if multilib_is_native_abi; then
		ln -s {"${S}"/,}docs/reference/libnice/html || die
	fi
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}

multilib_src_test() {
	emake -j1 check
}
