# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME2_LA_PUNT="yes"
GNOME_TARBALL_SUFFIX="gz"

inherit autotools flag-o-matic gnome2 toolchain-funcs multilib-minimal

DESCRIPTION="The GTK Project (formerly GTK+, The GIMP Toolkit)"
HOMEPAGE="https://www.gtk.org/"

LICENSE="LGPL-2.1+"
SLOT="1"
KEYWORDS="*"

IUSE="+debug nls"

# Supported languages and translated documentation
# Be sure all languages are prefixed with a single space!
MY_AVAILABLE_LINGUAS=" az ca cs da de el es et eu fi fr ga gl hr hu it ja ko lt nl nn no pl pt_BR pt ro ru sk sl sr sv tr uk vi"
IUSE="${IUSE} ${MY_AVAILABLE_LINGUAS// / linguas_}"

RDEPEND="
	>=dev-libs/glib-1.2.10-r6:1[${MULTILIB_USEDEP}]
	>=x11-libs/libX11-1.5.0-r1[${MULTILIB_USEDEP}]
	>=x11-libs/libXext-1.3.1-r1[${MULTILIB_USEDEP}]
	>=x11-libs/libXi-1.7.2[${MULTILIB_USEDEP}]
	>=x11-libs/libXt-1.1.4[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	x11-base/xorg-proto
	nls? ( sys-devel/gettext dev-util/intltool )
"

MULTILIB_CHOST_TOOLS=(/usr/bin/gtk-config)

src_prepare() {
	append-cflags -std=gnu89
	eapply "${FILESDIR}"/${PN}-1.2.10-m4.patch
	eapply "${FILESDIR}"/${PN}-1.2.10-automake.patch
	eapply "${FILESDIR}"/${PN}-1.2.10-cleanup.patch
	eapply "${FILESDIR}"/${PN}-1.2.10-r8-gentoo.diff
	eapply "${FILESDIR}"/${PN}-1.2-locale_fix.patch
	eapply "${FILESDIR}"/${PN}-1.2.10-as-needed.patch
	sed -i '/libtool.m4/,/AM_PROG_NM/d' acinclude.m4 #168198
	eapply "${FILESDIR}"/${PN}-1.2.10-automake-1.13.patch #467520
	mv configure.in configure.ac || die #426262
	eautoreconf
	gnome2_src_prepare
}

multilib_src_configure() {
	local myconf=
	use nls || myconf="${myconf} --disable-nls"
	strip-linguas ${MY_AVAILABLE_LINGUAS}

	if use debug ; then
		myconf="${myconf} --enable-debug=yes"
	else
		myconf="${myconf} --enable-debug=minimum"
	fi

	ECONF_SOURCE="${S}" \
	gnome2_src_configure \
		--disable-static \
		--sysconfdir="${EPREFIX}"/etc \
		--with-xinput=xfree \
		--with-x \
		${myconf} \
		GLIB_CONFIG="/usr/bin/${CHOST}-glib-config"
}

multilib_src_compile() {
	emake CC="$(tc-getCC)"
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_install_all() {
	einstalldocs
	docinto docs
	cd docs
	dodoc *.txt *.gif text/*
	docinto html
	dodoc -r html/.

	#install nice, clean-looking gtk+ style
	insinto /usr/share/themes/Gentoo/gtk
	doins "${FILESDIR}"/gtkrc
}

pkg_postinst() {
	if [[ -e /etc/X11/gtk/gtkrc ]] ; then
		ewarn "Older versions added /etc/X11/gtk/gtkrc which changed settings for"
		ewarn "all themes it seems.  Please remove it manually as it will not due"
		ewarn "to /env protection."
	fi

	echo ""
	einfo "The old gtkrc is available through the new Gentoo gtk theme."
}
