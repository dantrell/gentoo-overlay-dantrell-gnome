# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit autotools elisp-common flag-o-matic

DESCRIPTION="GNU Ubiquitous Intelligent Language for Extensions"
HOMEPAGE="https://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.xz"

LICENSE="LGPL-3+"
SLOT="12/22" # subslot is soname version
KEYWORDS="*"

IUSE="debug debug-malloc +deprecated doc emacs +networking +nls +regex static-libs +threads" # upstream recommended +networking +nls
REQUIRED_USE="regex" # workaround for bug #596322

RESTRICT="mirror strip"

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
	doc? ( sys-apps/texinfo )
	emacs? ( >=app-editors/emacs-23.1:* )
	virtual/pkgconfig
	dev-build/libtool
	sys-devel/gettext
"

# guile generates ELF files without use of C or machine code
# It's a false positive. bug #677600
QA_PREBUILT='*[.]go'

PATCHES=(
	"${FILESDIR}"/${PN}-2-snarf.patch
	"${FILESDIR}"/${PN}-2.0.14-darwin.patch
	"${FILESDIR}"/${PN}-2.0.14-ia64-fix-crash-thread-context-switch.patch
	"${FILESDIR}"/${PN}-2.0.14-configure-clang16.patch
)

src_prepare() {
	default

	# Can drop once guile-2.0.14-configure-clang16.patch merged
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

	local -a myconf=(
		--disable-error-on-warning
		--disable-rpath
		--disable-static
		--enable-posix
		--with-modules
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
		$(use_enable static-libs static)
		$(use_with threads)
	)
	econf ${myconf[@]}
}

src_install() {
	default

	if use doc; then
		dodoc GUILE-VERSION HACKING
	fi

	# Necessary for avoiding ldconfig warnings
	# 	https://bugzilla.novell.com/show_bug.cgi?id=874028#c0
	dodir /usr/share/gdb/auto-load/$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/libguile-*-gdb.scm "${ED}"/usr/share/gdb/auto-load/$(get_libdir) || die

	# Necessary for registering SLIB
	# 	https://bugs.gentoo.org/206896
	keepdir /usr/share/guile/site

	# Necessary for some dependencies
	dosym libguile-2.0.so /usr/$(get_libdir)/libguile.so

	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_prerm() {
	rm -f "${EROOT}"/usr/share/guile/site/slibcat
}

pkg_postrm() {
	use emacs && elisp-site-regen
}

pkg_config() {
	if has_version '>=dev-scheme/slib-3.2.4'; then
		einfo "Registering slib with guile"
		install_slib_for_guile
	fi
}
