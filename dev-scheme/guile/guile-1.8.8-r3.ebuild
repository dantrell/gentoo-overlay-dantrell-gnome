# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools flag-o-matic elisp-common

DESCRIPTION="GNU Ubiquitous Intelligent Language for Extensions"
HOMEPAGE="https://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="12"
MAJOR="1.8"
KEYWORDS="*"

IUSE="debug debug-freelist debug-malloc +deprecated discouraged doc emacs networking nls readline +regex +threads"

RESTRICT="!regex? ( test )"

RDEPEND="
	!dev-scheme/guile:2

	>=dev-libs/gmp-4.1:0=
	dev-libs/libltdl:0=
	sys-devel/gettext
	sys-libs/ncurses:0=
	emacs? ( >=app-editors/emacs-23.1:* )
	readline? ( sys-libs/readline:0= )"
DEPEND="${RDEPEND}
	sys-apps/texinfo
	sys-devel/libtool"

src_prepare() {
	eapply "${FILESDIR}"/${P}-fix_guile-config.patch
	eapply "${FILESDIR}"/${P}-gcc46.patch
	eapply "${FILESDIR}"/${P}-gcc5.patch
	eapply "${FILESDIR}"/${P}-makeinfo-5.patch
	eapply "${FILESDIR}"/${P}-gtexinfo-5.patch
	eapply "${FILESDIR}"/${P}-readline.patch
	eapply "${FILESDIR}"/${P}-tinfo.patch
	eapply "${FILESDIR}"/${P}-sandbox.patch
	eapply "${FILESDIR}"/${P}-mkdir-mask.patch
	eapply "${FILESDIR}"/${PN}-1.8.8-texinfo-6.7.patch

	sed -e "s/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/g" \
		-e "/AM_PROG_CC_STDC/d" \
		-i guile-readline/configure.in || die

	epatch_user

	mv "${S}"/configure.{in,ac} || die
	mv "${S}"/guile-readline/configure.{in,ac} || die

	eautoreconf
}

src_configure() {
	# Seems to have issues with -Os, switch to -O2
	# 	https://bugs.funtoo.org/browse/FL-2584
	replace-flags -Os -O2

	# Necessary for LilyPond
	# 	https://bugs.gentoo.org/178499
	filter-flags -ftree-vectorize

	econf \
		--disable-error-on-warning \
		--disable-rpath \
		--disable-static \
		--enable-posix \
		--with-modules \
		$(use deprecated || use_enable discouraged) \
		$(use_enable debug-freelist) \
		$(use_enable debug guile-debug) \
		$(use_enable debug-malloc) \
		$(use_enable deprecated) \
		$(use_enable emacs elisp) \
		$(use_enable networking) \
		$(use_enable nls) \
		$(use_enable readline) \
		$(use_enable regex) \
		$(use_with threads) \
		EMACS=no
}

src_compile() {
	emake

	# Above we have disabled the build system's Emacs support;
	# for USE=emacs we compile (and install) the files manually
	if use emacs; then
		cd emacs || die
		elisp-compile *.el || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install

	if use doc; then
		dodoc AUTHORS ChangeLog GUILE-VERSION HACKING NEWS README THANKS
	fi

	if use emacs; then
		elisp-install ${PN} emacs/*.{el,elc} || die
		elisp-site-file-install "${FILESDIR}"/50${PN}-gentoo.el || die
	fi

	# Necessary for avoiding ldconfig warnings
	# 	https://bugzilla.novell.com/show_bug.cgi?id=874028#c0
	dodir /usr/share/gdb/auto-load/$(get_libdir)
	mv ${D}/usr/$(get_libdir)/libguile-*-gdb.scm ${D}/usr/share/gdb/auto-load/$(get_libdir)

	# Necessary for TeXmacs
	# 	https://bugs.gentoo.org/23493
	dodir /etc/env.d
	echo "GUILE_LOAD_PATH=\"${EPREFIX}/usr/share/guile/${MAJOR}\"" > "${ED}"/etc/env.d/50guile

	# Necessary for registering SLIB
	# 	https://bugs.gentoo.org/206896
	keepdir /usr/share/guile/site
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
	if has_version dev-scheme/slib; then
		einfo "Registering slib with guile"
		install_slib_for_guile
	fi
}
