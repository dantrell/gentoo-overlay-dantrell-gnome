# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )
DISTUTILS_OPTIONAL=1

inherit distutils-r1 eutils qmake-utils

DESCRIPTION="GnuPG Made Easy is a library for making GnuPG easier to use"
HOMEPAGE="http://www.gnupg.org/related_software/gpgme"
SRC_URI="mirror://gnupg/gpgme/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="1/11" # subslot = soname major version
KEYWORDS="*"

IUSE="common-lisp static-libs cxx python qt5"
REQUIRED_USE="qt5? ( cxx )"

RDEPEND="app-crypt/gnupg
	>=dev-libs/libassuan-2.0.2
	>=dev-libs/libgpg-error-1.11
	cxx? (
		!kde-apps/gpgmepp:4
		!kde-apps/kdepimlibs:4
	)
	qt5? (
		dev-qt/qtcore:5
		!kde-apps/gpgmepp:4
		!kde-apps/kdepimlibs:4
	)
	python? ( ${PYTHON_DEPS} )"
		#doc? ( app-doc/doxygen[dot] )
DEPEND="${RDEPEND}
	python? ( dev-lang/swig )
	qt5? ( dev-qt/qttest:5 )"

PATCHES=(
	"${FILESDIR}"/${PN}-1.1.8-et_EE.patch
)

do_python() {
	if use python; then
		pushd lang/python > /dev/null || die
		distutils-r1_src_${EBUILD_PHASE}
		popd > /dev/null
	fi
}

src_prepare() {
	default
	do_python
}

src_configure() {
	local languages=()
	use common-lisp && languages+=( "cl" )
	use cxx && languages+=( "cpp" )
	if use qt5; then
		languages+=( "qt" )
		#use doc ||
		export DOXYGEN=true
		export MOC="$(qt5_get_bindir)/moc"
	fi

	econf \
		--enable-languages="${languages[*]}" \
		$(use_enable static-libs static)

	use python && make -C lang/python prepare

	do_python
}

src_compile() {
	default
	do_python
}

src_install() {
	default
	do_python
	prune_libtool_files

	# backward compatibility for gentoo
	# in the past we had slots
	dodir /usr/include/gpgme
	dosym ../gpgme.h /usr/include/gpgme/gpgme.h
}
