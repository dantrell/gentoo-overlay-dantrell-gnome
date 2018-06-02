# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cmake-utils

DESCRIPTION="A linkable library for Git"
HOMEPAGE="https://libgit2.github.com/"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2-with-linking-exception"
SLOT="0/26"
KEYWORDS="*"

IUSE="+curl examples gssapi libressl +ssh test +threads trace"

RDEPEND="
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	sys-libs/zlib
	net-libs/http-parser:=
	curl? (
		!libressl? ( net-misc/curl:=[curl_ssl_openssl(-)] )
		libressl? ( net-misc/curl:=[curl_ssl_libressl(-)] )
	)
	gssapi? ( virtual/krb5 )
	ssh? ( net-libs/libssh2 )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

DOCS=( AUTHORS CONTRIBUTING.md CONVENTIONS.md README.md )

src_prepare() {
	# skip online tests
	sed -i '/libgit2_clar/s/-ionline/-xonline/' CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLIB_INSTALL_DIR="${EPREFIX}/usr/$(get_libdir)"
		-DBUILD_CLAR=$(usex test)
		-DENABLE_TRACE=$(usex trace)
		-DUSE_GSSAPI=$(usex gssapi)
		-DUSE_SSH=$(usex ssh)
		-DTHREADSAFE=$(usex threads)
		-DCURL=$(usex curl)
	)
	cmake-utils_src_configure
}

src_test() {
	if [[ ${EUID} -eq 0 ]] ; then
		# repo::iterator::fs_preserves_error fails if run as root
		# since root can still access dirs with 0000 perms
		ewarn "Skipping tests: non-root privileges are required for all tests to pass"
	else
		local TEST_VERBOSE=1
		cmake-utils_src_test
	fi
}

src_install() {
	cmake-utils_src_install

	if use examples ; then
		find examples -name '.gitignore' -delete || die
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
