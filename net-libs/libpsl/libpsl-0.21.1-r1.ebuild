# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit flag-o-matic multilib-minimal python-any-r1

DESCRIPTION="C library for the Public Suffix List"
HOMEPAGE="https://github.com/rockdaboot/libpsl"
SRC_URI="https://github.com/rockdaboot/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

IUSE="icu +idn +man"

RDEPEND="
	icu? ( !idn? ( dev-libs/icu:=[${MULTILIB_USEDEP}] ) )
	idn? (
		dev-libs/libunistring:=[${MULTILIB_USEDEP}]
		net-dns/libidn2:=[${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}
	dev-build/gtk-doc-am
	sys-devel/gettext
	virtual/pkgconfig
	man? ( dev-libs/libxslt )
"

pkg_pretend() {
	if use icu && use idn ; then
		ewarn "\"icu\" and \"idn\" USE flags are enabled. Using \"idn\"."
	fi
}

multilib_src_configure() {
	# bug #880077, https://github.com/rockdaboot/libpsl/pull/189
	append-lfs-flags

	local myeconfargs=(
		--disable-asan
		--disable-cfi
		--disable-ubsan
		--disable-static
		$(use_enable man)
	)

	# Prefer idn even if icu is in USE as well
	if use idn ; then
		myeconfargs+=(
			--enable-builtin=libidn2
			--enable-runtime=libidn2
		)
	elif use icu ; then
		myeconfargs+=(
			--enable-builtin=libicu
			--enable-runtime=libicu
		)
	else
		myeconfargs+=( --disable-runtime )
	fi

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install() {
	default

	find "${ED}" -type f -name "*.la" -delete || die
}
