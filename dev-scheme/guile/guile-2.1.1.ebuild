# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils flag-o-matic

DESCRIPTION="GNU Ubiquitous Intelligent Language for Extensions"
HOMEPAGE="https://www.gnu.org/software/guile/"
SRC_URI="http://alpha.gnu.org/gnu/${PN}/${P}.tar.xz"

RESTRICT="mirror"

LICENSE="LGPL-3+"
SLOT="12"
KEYWORDS=""
IUSE="debug debug-malloc +deprecated doc emacs networking nls +regex static +threads"

RESTRICT="mirror"

RDEPEND="
	!dev-scheme/guile:2

	>=dev-libs/boehm-gc-7.0[threads?]
	dev-libs/gmp:0
	dev-libs/libffi
	dev-libs/libunistring
	sys-devel/gettext
	>=sys-devel/libtool-1.5.6
	virtual/libiconv
	virtual/libintl

	doc? ( sys-apps/texinfo )
	emacs? ( virtual/emacs )
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
"

src_configure() {
	# Seems to have issues with -Os, switch to -O2
	# 	https://bugs.funtoo.org/browse/FL-2584
	replace-flags -Os -O2

	# Necessary for LilyPond
	# 	https://bugs.gentoo.org/show_bug.cgi?id=178499
	filter-flags -ftree-vectorize

	econf \
		--disable-error-on-warning \
		--disable-rpath \
		--disable-static \
		--enable-posix \
		--with-modules \
		$(use_enable debug guile-debug) \
		$(use_enable debug-malloc) \
		$(use_enable deprecated) \
		$(use_enable networking) \
		$(use_enable nls) \
		$(use_enable regex) \
		$(use_enable static) \
		$(use_with threads)
}

src_install() {
	einstall

	if use doc; then
		dodoc AUTHORS COPYING COPYING.LESSER ChangeLog GUILE-VERSION HACKING LICENSE NEWS README THANKS || die
	fi

	# Necessary for TeXmacs
	# 	https://bugs.gentoo.org/show_bug.cgi?id=23493
	dodir /etc/env.d
	echo "GUILE_LOAD_PATH=\"${EPREFIX}/usr/share/guile/${MAJOR}\"" > "${ED}"/etc/env.d/50guile

	# Necessary for registering SLIB
	# 	https://bugs.gentoo.org/show_bug.cgi?id=206896
	keepdir /usr/share/guile/site

	# Necessary for avoiding ldconfig warnings
	# 	https://bugzilla.novell.com/show_bug.cgi?id=874028#c0
	dodir /usr/share/gdb/auto-load/$(get_libdir)
	mv ${D}/usr/$(get_libdir)/libguile-*-gdb.scm ${D}/usr/share/gdb/auto-load/$(get_libdir)
}

pkg_config() {
	if has_version dev-scheme/slib; then
		einfo "Registering slib with guile"
		install_slib_for_guile
	fi
}

_pkg_prerm() {
	rm -f "${EROOT}"/usr/share/guile/site/slibcat
}
