# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Qualcomm MSM (Mobile Station Modem) Interface (QMI) modem protocol library"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/libqmi/ https://gitlab.freedesktop.org/mobile-broadband/libqmi"
SRC_URI="https://www.freedesktop.org/software/libqmi/${P}.tar.xz"

LICENSE="LGPL-2"
SLOT="0/5.8"	# soname of libqmi-glib.so
KEYWORDS="*"

IUSE="gtk-doc +mbim +qrtr"

RDEPEND=">=dev-libs/glib-2.56
	>=dev-libs/libgudev-232
	mbim? ( >=net-libs/libmbim-1.18.0 )
	qrtr? ( >=net-libs/libqrtr-glib-1.0.0:= )
"
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
		$(use_enable qrtr)
		$(use_enable mbim mbim-qmux)
		$(use_enable gtk-doc)
	)
	econf "${myconf[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
