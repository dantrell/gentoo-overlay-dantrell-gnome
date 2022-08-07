# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python{3_8,3_9,3_10,3_11} )

inherit cmake-utils python-any-r1

DESCRIPTION="A linkable library for Git"
HOMEPAGE="https://libgit2.org/"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2-with-linking-exception"
SLOT="0/27"
KEYWORDS="*"

IUSE="+curl examples gssapi +ssh test +threads trace"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/openssl:0=
	sys-libs/zlib
	net-libs/http-parser:=
	curl? ( net-misc/curl:=[curl_ssl_openssl(-)] )
	gssapi? ( virtual/krb5 )
	ssh? ( net-libs/libssh2 )
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	virtual/pkgconfig
"

PATCHES=(
	# skip OOM tests on 32-bit systems
	# https://bugs.gentoo.org/669892
	# https://github.com/libgit2/libgit2/commit/415a8ae9c9b6ac18f0524b6af8e58408b426457d
	"${FILESDIR}"/libgit2-0.26.8-disable-oom-tests-on-32bit.patch
)

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
		cmake-utils_src_test -R offline
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
