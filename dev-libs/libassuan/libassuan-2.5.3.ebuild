# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit libtool

DESCRIPTION="IPC library used by GnuPG and GPGME"
HOMEPAGE="https://www.gnupg.org/related_software/libassuan/index.en.html"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="GPL-3 LGPL-2.1"
SLOT="0"
KEYWORDS="*"

RDEPEND=">=dev-libs/libgpg-error-1.8"
DEPEND="${RDEPEND}"

src_prepare() {
	default

	if [[ ${CHOST} == *-solaris* ]] ; then
		elibtoolize

		# fix standards conflict
		sed -i \
			-e '/_XOPEN_SOURCE/s/500/600/' \
			-e 's/_XOPEN_SOURCE_EXTENDED/_NO&/' \
			-e 's/__EXTENSIONS__/_NO&/' \
			configure || die
	fi
}

src_configure() {
	local myeconfargs=(
		--disable-static
		GPG_ERROR_CONFIG="${EROOT}/usr/bin/${CHOST}-gpg-error-config"
		$("${S}/configure" --help | grep -o -- '--without-.*-prefix')
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	# ppl need to use libassuan-config for --cflags and --libs
	find "${ED}" -type f -name '*.la' -delete || die
}
