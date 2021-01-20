# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit multilib

DESCRIPTION="Qualcomm MSM (Mobile Station Modem) Interface (QMI) modem protocol library"
HOMEPAGE="https://cgit.freedesktop.org/libqmi/"
SRC_URI="https://www.freedesktop.org/software/libqmi/${P}.tar.xz"

LICENSE="LGPL-2"
SLOT="0/5.4"	# soname of libqmi-glib.so
KEYWORDS="*"

IUSE="doc +mbim static-libs"

RDEPEND=">=dev-libs/glib-2.36
	dev-libs/libgudev
	mbim? ( >=net-libs/libmbim-1.18.0 )"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
	virtual/pkgconfig"

src_prepare() {
	default
	[[ -e configure ]] || eautoreconf
}

src_configure() {
	econf \
		--disable-more-warnings \
		$(use_enable mbim mbim-qmux) \
		$(use_enable static{-libs,}) \
		$(use_enable {,gtk-}doc)
}

src_install() {
	default
	use static-libs || rm -f "${ED}/usr/$(get_libdir)/${PN}-glib.la"
}
