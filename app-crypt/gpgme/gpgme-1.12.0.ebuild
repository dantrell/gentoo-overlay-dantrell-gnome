# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
DISTUTILS_OPTIONAL=1

inherit distutils-r1 flag-o-matic libtool qmake-utils toolchain-funcs

DESCRIPTION="GnuPG Made Easy is a library for making GnuPG easier to use"
HOMEPAGE="https://www.gnupg.org/related_software/gpgme"
SRC_URI="mirror://gnupg/gpgme/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="1/11" # subslot = soname major version
KEYWORDS="*"

IUSE="common-lisp static-libs +cxx python qt5"
REQUIRED_USE="qt5? ( cxx ) python? ( ${PYTHON_REQUIRED_USE} )"

# Note: On each bump, update dep bounds on each version from configure.ac!
RDEPEND=">=app-crypt/gnupg-2
	>=dev-libs/libassuan-2.0.2:=
	>=dev-libs/libgpg-error-1.29:=
	python? ( ${PYTHON_DEPS} )
	qt5? ( dev-qt/qtcore:5 )"
	#doc? ( app-text/doxygen[dot] )
DEPEND="${RDEPEND}
	qt5? ( dev-qt/qttest:5 )"
BDEPEND="python? ( dev-lang/swig )"

do_python() {
	if use python; then
		pushd "lang/python" > /dev/null || die
		top_builddir="../.." srcdir="." CPP="$(tc-getCPP)" distutils-r1_src_${EBUILD_PHASE}
		popd > /dev/null
	fi
}

pkg_setup() {
	addpredict /run/user/$(id -u)/gnupg

	local MAX_WORKDIR=66
	if [[ "${#WORKDIR}" -gt "${MAX_WORKDIR}" ]]; then
		ewarn "Disabling tests as WORKDIR '${WORKDIR}' is longer than ${MAX_WORKDIR} which will fail tests"
		SKIP_TESTS=1
	fi
}

src_prepare() {
	default
	elibtoolize

	# Make best effort to allow longer PORTAGE_TMPDIR
	# as usock limitation fails build/tests
	ln -s "${P}" "${WORKDIR}/b"
	S="${WORKDIR}/b"
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
		$([[ -n "${SKIP_TESTS}" ]] && echo "--disable-gpg-test --disable-gpgsm-test") \
		--enable-languages="${languages[*]}" \
		$(use_enable static-libs static)

	use python && make -C lang/python prepare

	do_python
}

src_compile() {
	default
	do_python
}

src_test() {
	[[ -z "${SKIP_TESTS}" ]] || return

	default
	if use python; then
		test_python() {
			emake -C lang/python/tests check \
				PYTHON=${EPYTHON} \
				PYTHONS=${EPYTHON} \
				TESTFLAGS="--python-libdir=${BUILD_DIR}/lib"
		}
		python_foreach_impl test_python
	fi
}

src_install() {
	default
	do_python
	find "${ED}" -type f -name '*.la' -delete || die

	# backward compatibility for gentoo
	# in the past we had slots
	dodir /usr/include/gpgme
	dosym ../gpgme.h /usr/include/gpgme/gpgme.h
}
