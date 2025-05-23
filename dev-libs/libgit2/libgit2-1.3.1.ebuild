# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit cmake python-any-r1

DESCRIPTION="A linkable library for Git"
HOMEPAGE="https://libgit2.org/"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2-with-linking-exception"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="*"

IUSE="examples gssapi +ssh test +threads trace"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/libpcre:=
	net-libs/http-parser:=
	sys-libs/zlib
	dev-libs/openssl:0=
	gssapi? ( virtual/krb5 )
	ssh? ( net-libs/libssh2 )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
"

S=${WORKDIR}/${P/_/-}

src_prepare() {
	cmake_src_prepare
	# relying on forked http-parser to support some obscure URI form
	sed -i -e '/empty_port/s:test:_&:' tests/network/url/parse.c || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_CLAR=$(usex test)
		-DENABLE_TRACE=$(usex trace ON OFF)
		-DUSE_GSSAPI=$(usex gssapi ON OFF)
		-DUSE_SSH=$(usex ssh)
		-DTHREADSAFE=$(usex threads)
		-DUSE_HTTP_PARSER=system
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
