# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit multilib-minimal toolchain-funcs

DESCRIPTION="GStreamer plugin for ICE (RFC 5245) support"
HOMEPAGE="https://nice.freedesktop.org/wiki/"
MY_P=libnice-${PV}
SRC_URI="https://nice.freedesktop.org/releases/${MY_P}.tar.gz"

LICENSE="|| ( MPL-1.1 LGPL-2.1 )"
SLOT="1.0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	~net-libs/libnice-${PV}[${MULTILIB_USEDEP}]
	media-libs/gstreamer:${SLOT}[${MULTILIB_USEDEP}]
	media-libs/gst-plugins-base:${SLOT}[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S=${WORKDIR}/${MY_P}

src_prepare() {
	default
	sed -e 's:$(top_builddir)/nice/libnice.la:$(NICE_LIBS):' \
		-i gst/Makefile.{am,in} || die "sed failed"
}

multilib_src_configure() {
	# gupnp is not used in the gst plugin.
	ECONF_SOURCE=${S} \
	econf \
		--disable-static \
		--disable-static-plugins \
		--without-gstreamer-0.10 \
		--with-gstreamer \
		--disable-introspection \
		--disable-gupnp
}

multilib_src_compile() {
	emake -C gst \
		NICE_LIBS="$($(tc-getPKG_CONFIG) --libs-only-l nice)"
}

multilib_src_test() {
	:
}

multilib_src_install() {
	emake -C gst DESTDIR="${D}" install
}

multilib_src_install_all() {
	find "${ED}" -name '*.la' -delete || die
}
