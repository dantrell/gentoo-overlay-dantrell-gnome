# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit libtool eutils

DESCRIPTION="IPC library used by GnuPG and GPGME"
HOMEPAGE="http://www.gnupg.org/related_software/libassuan/index.en.html"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="GPL-3 LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="static-libs"

RDEPEND=">=dev-libs/libgpg-error-1.8"
DEPEND="${RDEPEND}"

DOCS=( AUTHORS ChangeLog NEWS README THANKS TODO )

src_prepare() {
	default

	# for Solaris .so
	elibtoolize
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default
	# ppl need to use libassuan-config for --cflags and --libs
	prune_libtool_files
}
