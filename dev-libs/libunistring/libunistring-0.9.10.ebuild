# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils multilib-minimal libtool ltprune

DESCRIPTION="Library for manipulating Unicode and C strings according to Unicode standard"
HOMEPAGE="https://www.gnu.org/software/libunistring/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="LGPL-3 GPL-3"
SLOT="0/2"
KEYWORDS="*"

IUSE="doc static-libs"

PATCHES=(
	"${FILESDIR}"/${PN}-nodocs.patch
)

src_prepare() {
	default
	elibtoolize  # for Solaris shared libraries
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" \
	econf $(use_enable static-libs static)
}

multilib_src_install() {
	default

	prune_libtool_files
}

multilib_src_install_all() {
	default

	if use doc; then
		dohtml doc/*.html
		doinfo doc/*.info
	fi
}
