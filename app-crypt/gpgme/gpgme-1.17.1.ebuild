# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_8,3_9,3_10} )
DISTUTILS_OPTIONAL=1
VERIFY_SIG_OPENPGP_KEY_PATH="${BROOT}"/usr/share/openpgp-keys/gnupg.asc

inherit distutils-r1 libtool qmake-utils toolchain-funcs verify-sig

DESCRIPTION="GnuPG Made Easy is a library for making GnuPG easier to use"
HOMEPAGE="http://www.gnupg.org/related_software/gpgme"
SRC_URI="mirror://gnupg/gpgme/${P}.tar.bz2
	verify-sig? ( mirror://gnupg/gpgme/${P}.tar.bz2.sig )"

LICENSE="GPL-2 LGPL-2.1"
# Please check ABI on each bump, even if SONAMEs didn't change: bug #833355
# Use e.g. app-portage/iwdevtools integration with dev-libs/libabigail's abidiff.
# Subslot: SONAME of each: <libgpgme.libgpgmepp.libqgpgme>
SLOT="1/11.6.15"
KEYWORDS="*"

IUSE="common-lisp static-libs +cxx python qt5"
REQUIRED_USE="qt5? ( cxx ) python? ( ${PYTHON_REQUIRED_USE} )"

# Note: On each bump, update dep bounds on each version from configure.ac!
RDEPEND=">=app-crypt/gnupg-2
	>=dev-libs/libassuan-2.5.3:=
	>=dev-libs/libgpg-error-1.36:=
	python? ( ${PYTHON_DEPS} )
	qt5? ( dev-qt/qtcore:5 )"
	#doc? ( app-doc/doxygen[dot] )
DEPEND="${RDEPEND}
	qt5? ( dev-qt/qttest:5 )"
BDEPEND="python? ( dev-lang/swig )
	verify-sig? ( sec-keys/openpgp-keys-gnupg )"

do_python() {
	if use python; then
		pushd "lang/python" > /dev/null || die
		top_builddir="../.." srcdir="." CPP="$(tc-getCPP)" distutils-r1_src_${EBUILD_PHASE}
		popd > /dev/null || die
	fi
}

src_prepare() {
	default

	elibtoolize

	# bug #697456
	addpredict /run/user/$(id -u)/gnupg

	local MAX_WORKDIR=66
	if [[ "${#WORKDIR}" -gt "${MAX_WORKDIR}" ]]; then
		ewarn "Disabling tests as WORKDIR '${WORKDIR}' is longer than ${MAX_WORKDIR} which will fail tests"
		SKIP_TESTS=1
	fi

	# Make best effort to allow longer PORTAGE_TMPDIR
	# as usock limitation fails build/tests
	ln -s "${P}" "${WORKDIR}/b" || die
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

	# bug #811933 for libassuan prefix
	econf \
		$([[ -n "${SKIP_TESTS}" ]] && echo "--disable-gpg-test --disable-gpgsm-test") \
		--enable-languages="${languages[*]}" \
		--with-libassuan-prefix="${ESYSROOT}"/usr \
		$(use_enable static-libs static)

	use python && emake -C lang/python prepare

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