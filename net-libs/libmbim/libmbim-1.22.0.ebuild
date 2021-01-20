# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit multilib

DESCRIPTION="Mobile Broadband Interface Model (MBIM) modem protocol helper library"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/libmbim/ https://gitlab.freedesktop.org/mobile-broadband/libmbim"
SRC_URI="https://www.freedesktop.org/software/libmbim/${P}.tar.xz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~*"

IUSE="static-libs udev"

RDEPEND=">=dev-libs/glib-2.36:2
	udev? ( dev-libs/libgudev:= )"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/gtk-doc-am
	virtual/pkgconfig
"

src_configure() {
	econf \
		--disable-more-warnings \
		--disable-gtk-doc \
		$(use_with udev) \
		$(use_enable static{-libs,})
}

src_install() {
	default
	use static-libs || rm -f "${ED}/usr/$(get_libdir)/${PN}-glib.la"
}
