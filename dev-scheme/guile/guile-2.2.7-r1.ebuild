# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit autotools

DESCRIPTION="GNU Ubiquitous Intelligent Language for Extensions"
HOMEPAGE="https://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.xz"

LICENSE="LGPL-3+"
SLOT="12/2.2-1" # libguile-2.2.so.1 => 2.2-1
KEYWORDS="~*"

IUSE="debug debug-malloc +deprecated +networking +nls +regex +threads" # upstream recommended +networking +nls
REQUIRED_USE="regex" # workaround for bug #596322

RESTRICT="strip"

RDEPEND="
	>=dev-libs/boehm-gc-7.0:=[threads?]
	dev-libs/gmp:=
	dev-libs/libffi:=
	dev-libs/libltdl:=
	dev-libs/libunistring:0=
	sys-libs/ncurses:0=
	sys-libs/readline:0=
	virtual/libcrypt:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	dev-build/libtool
	sys-devel/gettext
"

# guile generates ELF files without use of C or machine code
# It's a false positive. bug #677600
QA_PREBUILT='*[.]go'

PATCHES=(
	"${FILESDIR}"/${PN}-2.2.3-gentoo-sandbox.patch
	"${FILESDIR}"/${PN}-2.2.7-stack-up.patch
	"${FILESDIR}"/${PN}-3.0.8-configure-clang16.patch
)

src_prepare() {
	default

	# Can drop once guile-3.0.8-configure-clang16.patch merged
	eautoreconf
}

src_configure() {
	# Seems to have issues with -Os, switch to -O2
	# 	https://bugs.funtoo.org/browse/FL-2584
	replace-flags -Os -O2

	# Necessary for LilyPond
	# 	https://bugs.gentoo.org/178499
	filter-flags -ftree-vectorize

	# Seems to have issues with -gddb3, switch to -gddb2
	# 	https://bugs.gentoo.org/608190
	replace-flags -ggdb[3-9] -ggdb2

	# Seems to have issues with HPPA/PPC/SPARC
	# 	https://bugs.gentoo.org/676468
	mv prebuilt/32-bit-big-endian{,.broken} || die

	local -a myconf=(
		--disable-error-on-warning
		--disable-rpath
		--disable-static
		--enable-posix
		--without-libgmp-prefix
		--without-libiconv-prefix
		--without-libintl-prefix
		--without-libltdl-prefix
		--without-libreadline-prefix
		--without-libunistring-prefix
		$(use_enable debug guile-debug)
		$(use_enable debug-malloc)
		$(use_enable deprecated)
		$(use_enable networking)
		$(use_enable nls)
		$(use_enable regex)
		$(use_with threads)
	)
	econf ${myconf[@]}
}

src_install() {
	default

	# Necessary for avoiding ldconfig warnings
	# 	https://bugzilla.novell.com/show_bug.cgi?id=874028#c0
	dodir /usr/share/gdb/auto-load/$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/libguile-*-gdb.scm "${ED}"/usr/share/gdb/auto-load/$(get_libdir) || die

	# Necessary for registering SLIB
	# 	https://bugs.gentoo.org/206896
	keepdir /usr/share/guile/site

	find "${ED}" -name '*.la' -delete || die
}
