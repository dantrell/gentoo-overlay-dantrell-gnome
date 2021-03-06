# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_6,3_7,3_8,3_9} )
PYTHON_REQ_USE="wide-unicode(+)"
DISTUTILS_OPTIONAL=1

inherit autotools distutils-r1

DESCRIPTION="An open-source braille translator and back-translator"
HOMEPAGE="http://liblouis.org/ https://github.com/liblouis/liblouis"
SRC_URI="https://github.com/liblouis/liblouis/releases/download/v${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="python"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

BDEPEND="sys-apps/help2man"
RDEPEND="python? ( ${PYTHON_DEPS} )"
DEPEND="${RDEPEND}"

src_prepare() {
	default

	if use python; then
		pushd python > /dev/null
		distutils-r1_src_prepare
		popd > /dev/null
	fi
	eautoreconf
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
	emake DESTDIR="${D}" install

	if use python; then
		pushd python > /dev/null
		LD_PRELOAD+=':../liblouis/.libs/liblouis.so' \
			distutils-r1_src_install
		popd > /dev/null
	fi

	DOCS=( README AUTHORS NEWS ChangeLog doc/liblouis.txt )
	HTML_DOCS=( doc/liblouis.html )
	einstalldocs
}
