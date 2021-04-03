# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit multilib

DESCRIPTION="Qualcomm MSM (Mobile Station Modem) Interface (QMI) modem protocol library"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/libqmi/ https://gitlab.freedesktop.org/mobile-broadband/libqmi"
SRC_URI="https://www.freedesktop.org/software/libqmi/${P}.tar.xz"

LICENSE="LGPL-2"
SLOT="0/5.7"	# soname of libqmi-glib.so
KEYWORDS=""

IUSE="gtk-doc +mbim"

RDEPEND=">=dev-libs/glib-2.48
	dev-libs/libgudev
	mbim? ( >=net-libs/libmbim-1.18.0 )"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? ( dev-util/gtk-doc )"

src_prepare() {
	default
}

src_configure() {
	local myconf=(
		--disable-Werror
		--disable-static
		--disable-qrtr # libqrtr-glib not packaged
		$(use_enable mbim mbim-qmux)
		$(use_enable gtk-doc)
	)
	econf "${myconf[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
