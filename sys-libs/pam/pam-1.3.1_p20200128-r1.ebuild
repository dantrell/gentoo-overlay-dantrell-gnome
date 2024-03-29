# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools db-use fcaps toolchain-funcs usr-ldscript multilib-minimal

DESCRIPTION="Linux-PAM (Pluggable Authentication Modules)"
HOMEPAGE="https://github.com/linux-pam/linux-pam"

COMMIT_HASH="4dd9b97b762cc73816cb867d49c9d0d0b91d642c"
SRC_URI="https://github.com/linux-pam/linux-pam/archive/${COMMIT_HASH}.tar.gz#/${PN}-${COMMIT_HASH}.tar.gz"

LICENSE="|| ( BSD GPL-2 )"
SLOT="0"
KEYWORDS="*"

IUSE="audit berkdb +cracklib debug nis selinux static-libs"

BDEPEND="app-text/docbook-xml-dtd:4.1.2
	app-text/docbook-xml-dtd:4.3
	app-text/docbook-xml-dtd:4.4
	app-text/docbook-xml-dtd:4.5
	dev-libs/libxslt
	sys-devel/flex
	sys-devel/gettext
	virtual/pkgconfig
	app-alternatives/yacc"

DEPEND="
	virtual/libcrypt:=[${MULTILIB_USEDEP}]
	>=virtual/libintl-0-r1[${MULTILIB_USEDEP}]
	audit? ( >=sys-process/audit-2.2.2[${MULTILIB_USEDEP}] )
	berkdb? ( >=sys-libs/db-4.8.30-r1:=[${MULTILIB_USEDEP}] )
	cracklib? ( >=sys-libs/cracklib-2.9.1-r1[${MULTILIB_USEDEP}] )
	selinux? ( >=sys-libs/libselinux-2.2.2-r4[${MULTILIB_USEDEP}] )
	nis? ( >=net-libs/libtirpc-0.2.4-r2:=[${MULTILIB_USEDEP}] )"

RDEPEND="${DEPEND}"

PDEPEND="sys-auth/pambase"

S="${WORKDIR}/linux-${PN}-${COMMIT_HASH}"

src_prepare() {
	default
	eapply "${FILESDIR}"/${PN}-remove-browsers.patch
	touch ChangeLog || die
	eautoreconf
}

multilib_src_configure() {
	# Do not let user's BROWSER setting mess us up. #549684
	unset BROWSER

	# Disable automatic detection of libxcrypt; we _don't_ want the
	# user to link libxcrypt in by default, since we won't track the
	# dependency and allow to break PAM this way.

	export ac_cv_header_xcrypt_h=no

	local myconf=(
		--with-db-uniquename=-$(db_findver sys-libs/db)
		--with-xml-catalog="${EPREFIX}"/etc/xml/catalog
		--enable-securedir="${EPREFIX}"/$(get_libdir)/security
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		--exec-prefix="${EPREFIX}"
		--enable-pie
		--disable-prelude
		--enable-doc
		$(use_enable audit)
		$(use_enable berkdb db)
		$(use_enable cracklib)
		$(use_enable debug)
		$(use_enable nis)
		$(use_enable selinux)
		$(use_enable static-libs static)
		--enable-isadir='.' #464016
		)
	ECONF_SOURCE="${S}" econf ${myconf[@]}
}

multilib_src_compile() {
	emake sepermitlockdir="${EPREFIX}/run/sepermit"
}

multilib_src_install() {
	emake DESTDIR="${D}" install \
		sepermitlockdir="${EPREFIX}/run/sepermit"

	gen_usr_ldscript -a pam pam_misc pamc
}

multilib_src_install_all() {
	find "${ED}" -type f -name '*.la' -delete || die

	if use selinux; then
		dodir /usr/lib/tmpfiles.d
		cat - > "${D}"/usr/lib/tmpfiles.d/${CATEGORY}:${PN}:${SLOT}.conf <<EOF
d /run/sepermit 0755 root root
EOF
	fi
}

pkg_postinst() {
	ewarn "Some software with pre-loaded PAM libraries might experience"
	ewarn "warnings or failures related to missing symbols and/or versions"
	ewarn "after any update. While unfortunate this is a limit of the"
	ewarn "implementation of PAM and the software, and it requires you to"
	ewarn "restart the software manually after the update."
	ewarn ""
	ewarn "You can get a list of such software running a command like"
	ewarn "  lsof / | grep -E -i 'del.*libpam\\.so'"
	ewarn ""
	ewarn "Alternatively, simply reboot your system."

	# The pam_unix module needs to check the password of the user which requires
	# read access to /etc/shadow only.
	fcaps cap_dac_override sbin/unix_chkpwd
}
