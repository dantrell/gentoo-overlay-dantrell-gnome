# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit libtool ltprune

DESCRIPTION="New GNU Portable Threads Library"
HOMEPAGE="https://git.gnupg.org/cgi-bin/gitweb.cgi?p=npth.git"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~*"

IUSE="static-libs"

src_prepare() {
	default
	elibtoolize  # for Solaris shared library
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default
	prune_libtool_files
}
