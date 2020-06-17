# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="PAM base configuration files"
HOMEPAGE="https://github.com/gentoo/pambase"
SRC_URI="https://github.com/gentoo/pambase/archive/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"

IUSE="caps ck consolekit debug elogind minimal mktemp +nullok pam_krb5 pam_ssh +passwdqc securetty selinux +sha512 systemd"
REQUIRED_USE="?? ( ck consolekit elogind systemd )"

RESTRICT="binchecks"

MIN_PAM_REQ=1.4.0

RDEPEND="
	>=sys-libs/pam-${MIN_PAM_REQ}
	ck? ( <sys-auth/consolekit-0.9[pam] )
	consolekit? ( >=sys-auth/consolekit-0.9[pam] )
	elogind? ( sys-auth/elogind[pam] )
	mktemp? ( sys-auth/pam_mktemp )
	pam_krb5? (
		>=sys-libs/pam-${MIN_PAM_REQ}
		sys-auth/pam_krb5
	)
	caps? ( sys-libs/libcap[pam] )
	pam_ssh? ( sys-auth/pam_ssh )
	passwdqc? ( sys-auth/passwdqc )
	selinux? ( sys-libs/pam[selinux] )
	sha512? ( >=sys-libs/pam-${MIN_PAM_REQ} )
	systemd? ( sys-apps/systemd[pam] )
"
DEPEND="
	app-arch/xz-utils
	app-portage/portage-utils
"

S="${WORKDIR}/${PN}-${P}"

src_compile() {
	local linux_pam_version
	if has_version sys-libs/pam; then
		local ver_str=$(qatom $(best_version sys-libs/pam) | cut -d ' ' -f 3)
		linux_pam_version=$(printf "0x%02x%02x%02x" ${ver_str//\./ })
	fi

	use_var() {
		local varname=$(echo "$1" | tr '[:lower:]' '[:upper:]')
		local usename=${2-$(echo "$1" | tr '[:upper:]' '[:lower:]')}
		local varvalue=$(usex ${usename})
		echo "${varname}=${varvalue}"
	}

	local myconf=()
	if use ck; then
		myconf+=( $(use_var consolekit ck) )
	elif use consolekit; then
		myconf+=( $(use_var consolekit) )
	elif use elogind; then
		myconf+=( $(use_var elogind) )
	elif use systemd; then
		myconf+=( $(use_var systemd) )
	fi

	emake \
		GIT=true \
		$(use_var debug) \
		$(use_var LIBCAP caps) \
		$(use_var passwdqc) \
		"${myconf[@]}" \
		$(use_var selinux) \
		$(use_var nullok) \
		$(use_var mktemp) \
		$(use_var pam_ssh) \
		$(use_var securetty) \
		$(use_var sha512) \
		$(use_var KRB5 pam_krb5) \
		$(use_var minimal) \
		LINUX_PAM_VERSION=${linux_pam_version}
}

src_test() { :; }

src_install() {
	emake GIT=true DESTDIR="${ED}" install
}
