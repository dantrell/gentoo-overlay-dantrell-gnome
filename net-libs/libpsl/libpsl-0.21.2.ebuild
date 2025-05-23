# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit meson-multilib python-any-r1

DESCRIPTION="C library for the Public Suffix List"
HOMEPAGE="https://github.com/rockdaboot/libpsl"
SRC_URI="https://github.com/rockdaboot/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~*"

IUSE="icu +idn"

RDEPEND="
	icu? ( !idn? ( dev-libs/icu:=[${MULTILIB_USEDEP}] ) )
	idn? (
		dev-libs/libunistring:=[${MULTILIB_USEDEP}]
		net-dns/libidn2:=[${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	sys-devel/gettext
	virtual/pkgconfig
"

pkg_pretend() {
	if use icu && use idn ; then
		ewarn "\"icu\" and \"idn\" USE flags are enabled. Using \"idn\"."
	fi
}

multilib_src_configure() {
	local emesonargs=()

	# Prefer idn even if icu is in USE as well
	if use idn ; then
		emesonargs+=(
			-Druntime=libidn2
			-Dbuiltin=true
		)
	elif use icu ; then
		emesonargs+=(
			-Druntime=libicu
			-Dbuiltin=true
		)
	else
		emesonargs+=(
			-Druntime=no
		)
	fi

	meson_src_configure
}
