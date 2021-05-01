# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_6,3_7,3_8,3_9} )

inherit cmake python-any-r1

DESCRIPTION="A linkable library for Git"
HOMEPAGE="https://libgit2.org"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2-with-linking-exception"
SLOT="0/28"
KEYWORDS="*"

IUSE="examples gssapi +ssh test +threads trace"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/openssl:0=
	sys-libs/zlib
	net-libs/http-parser:=
	gssapi? ( virtual/krb5 )
	ssh? ( net-libs/libssh2 )
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	virtual/pkgconfig
"

S=${WORKDIR}/${P/_/-}

src_configure() {
	local mycmakeargs=(
		-DLIB_INSTALL_DIR="${EPREFIX}/usr/$(get_libdir)"
		-DBUILD_CLAR=$(usex test)
		-DENABLE_TRACE=$(usex trace)
		-DUSE_GSSAPI=$(usex gssapi)
		-DUSE_SSH=$(usex ssh)
		-DTHREADSAFE=$(usex threads)
	)
	cmake_src_configure
}

src_test() {
	if [[ ${EUID} -eq 0 ]] ; then
		# repo::iterator::fs_preserves_error fails if run as root
		# since root can still access dirs with 0000 perms
		ewarn "Skipping tests: non-root privileges are required for all tests to pass"
	else
		local TEST_VERBOSE=1
		cmake_src_test -R offline
	fi
}

src_install() {
	cmake_src_install
	dodoc docs/*.{md,txt}

	if use examples ; then
		find examples -name '.gitignore' -delete || die
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
