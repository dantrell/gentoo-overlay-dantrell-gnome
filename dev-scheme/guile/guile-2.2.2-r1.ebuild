# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit elisp-common flag-o-matic ltprune

DESCRIPTION="GNU Ubiquitous Intelligent Language for Extensions"
HOMEPAGE="https://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.xz"

LICENSE="LGPL-3+"
SLOT="12"
KEYWORDS=""

IUSE="debug debug-malloc +deprecated doc emacs +networking +nls +regex static-libs +threads" # upstream recommended +networking +nls

RESTRICT="mirror"

RDEPEND="
	!dev-scheme/guile:2

	>=dev-libs/boehm-gc-7.0[threads?]
	>=dev-libs/gmp-4.2:0=
	virtual/libffi
	dev-libs/libltdl:=
	>=dev-libs/libunistring-0.9.3
	>=sys-devel/libtool-1.5.6
	sys-libs/readline:0=
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
	doc? ( sys-apps/texinfo )
	emacs? ( virtual/emacs )
	sys-devel/gettext
"

src_configure() {
	# Seems to have issues with -Os, switch to -O2
	# 	https://bugs.funtoo.org/browse/FL-2584
	replace-flags -Os -O2

	# Necessary for LilyPond
	# 	https://bugs.gentoo.org/show_bug.cgi?id=178499
	filter-flags -ftree-vectorize

	# Seems to have issues with -gddb3, switch to -gddb2
	# 	https://bugs.gentoo.org/show_bug.cgi?id=608190
	replace-flags -ggdb[3-9] -ggdb2

	econf \
		--disable-error-on-warning \
		--disable-rpath \
		--disable-static \
		--enable-posix \
		--with-modules \
		--without-libgmp-prefix \
		--without-libiconv-prefix \
		--without-libintl-prefix \
		--without-libltdl-prefix \
		--without-libreadline-prefix \
		--without-libunistring-prefix \
		$(use_enable debug guile-debug) \
		$(use_enable debug-malloc) \
		$(use_enable deprecated) \
		$(use_enable networking) \
		$(use_enable nls) \
		$(use_enable regex) \
		$(use_enable static-libs static) \
		$(use_with threads)
}

src_install() {
	default
	prune_libtool_files

	if use doc; then
		dodoc GUILE-VERSION HACKING
	fi

	# Necessary for avoiding ldconfig warnings
	# 	https://bugzilla.novell.com/show_bug.cgi?id=874028#c0
	dodir /usr/share/gdb/auto-load/$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/libguile-*-gdb.scm "${ED}"/usr/share/gdb/auto-load/$(get_libdir) || die

	# Necessary for registering SLIB
	# 	https://bugs.gentoo.org/show_bug.cgi?id=206896
	keepdir /usr/share/guile/site

	# Necessary for some dependencies
	dosym libguile-2.0.so /usr/$(get_libdir)/libguile.so
}

pkg_postinst() {
	[[ "${EROOT}" == "/" ]] && pkg_config
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
