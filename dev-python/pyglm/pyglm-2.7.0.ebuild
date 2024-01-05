# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DISTUTILS_USE_PEP517=setuptools

PYTHON_COMPAT=( python{3_10,3_11,3_12} )

inherit distutils-r1

EGIT_COMMIT_GLM="efec5db081e3aad807d0731e172ac597f6a39447"
EGIT_COMMIT_TYPING="f47636b86d07d4f91692235e8dfe0af1bd22e883"

DESCRIPTION="OpenGL Mathematics (GLM) library for Python"
HOMEPAGE="https://pypi.org/project/PyGLM/"
SRC_URI="
	https://github.com/Zuzu-Typ/PyGLM/archive/refs/tags/${PV}-rev1.tar.gz -> ${P}.tar.gz
	https://github.com/g-truc/glm/archive/${EGIT_COMMIT_GLM}.tar.gz -> glm-${EGIT_COMMIT_GLM}.tar.gz
	https://github.com/esoma/pyglm-typing/archive/${EGIT_COMMIT_TYPING}.tar.gz -> pyglm-typing-${EGIT_COMMIT_TYPING}.tar.gz
"

S="${WORKDIR}/PyGLM-${PV}-rev1"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

BDEPEND="media-libs/glm"

src_unpack() {
	default

	rmdir "${S}/glm" || die
	mv "${WORKDIR}/glm-${EGIT_COMMIT_GLM}" "${S}/glm" || die

	rmdir "${S}/pyglm-typing" || die
	mv "${WORKDIR}/pyglm-typing-${EGIT_COMMIT_TYPING}" "${S}/pyglm-typing" || die
}

distutils_enable_tests pytest
