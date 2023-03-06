# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DISTUTILS_USE_PEP517=setuptools

PYTHON_COMPAT=( python{3_9,3_10,3_11} )

inherit distutils-r1

DESCRIPTION="Python bindings for the FreeType library"
HOMEPAGE="https://pypi.org/project/freetype-py/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

BDEPEND="media-libs/freetype:2"

distutils_enable_tests pytest
distutils_enable_sphinx doc dev-python/sphinx-rtd-theme
