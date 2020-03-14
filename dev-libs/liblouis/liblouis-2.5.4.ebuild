# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python{3_6,3_7,3_8} )
PYTHON_REQ_USE="wide-unicode(+)"
DISTUTILS_OPTIONAL=1

inherit distutils-r1

DESCRIPTION="An open-source braille translator, back-translator and formatter"
HOMEPAGE="http://www.liblouis.org/ https://github.com/liblouis/liblouis"
SRC_URI="http://liblouis.org/downloads/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="*"

IUSE="python"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="python? ( ${PYTHON_DEPS} )"
DEPEND="${RDEPEND}"

src_prepare() {
	default

	if use python; then
		pushd python > /dev/null
		distutils-r1_src_prepare
		popd > /dev/null
	fi
}

src_configure() {
	econf --enable-ucs4
}

src_compile() {
	default

	if use python; then
		pushd python > /dev/null
		# setup.py imports liblouis to get the version number,
		# and this causes the shared library to be dlopened
		# at build-time.  Hack around it with LD_PRELOAD.
		# Thanks ArchLinux.
		LD_PRELOAD+=':../liblouis/.libs/liblouis.so'
			distutils-r1_src_compile
		popd > /dev/null
	fi
}

src_install() {
	emake install DESTDIR="${D}"

	if use python; then
		pushd python > /dev/null
		LD_PRELOAD+=':../liblouis/.libs/liblouis.so' \
			distutils-r1_src_install
		popd > /dev/null
	fi

	dodoc README AUTHORS NEWS ChangeLog
	dohtml doc/liblouis.html
}
