# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_8,3_9,3_10,3_11} )

inherit pam python-any-r1 readme.gentoo-r1

DESCRIPTION="PAM base configuration files"
HOMEPAGE="https://github.com/gentoo/pambase"
SRC_URI="https://github.com/gentoo/pambase/archive/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

IUSE="caps ck consolekit debug elogind gnome-keyring minimal mktemp +nullok pam_krb5 pam_ssh +passwdqc pwhistory pwquality securetty selinux +sha512 systemd"
REQUIRED_USE="
	?? ( ck consolekit elogind systemd )
	?? ( passwdqc pwquality )
	pwhistory? ( || ( passwdqc pwquality ) )
"

RESTRICT="binchecks"

MIN_PAM_REQ=1.4.0

RDEPEND="
	>=sys-libs/pam-${MIN_PAM_REQ}
	ck? ( <sys-auth/consolekit-0.9[pam] )
	consolekit? ( >=sys-auth/consolekit-0.9[pam] )
	elogind? ( sys-auth/elogind[pam] )
	gnome-keyring? ( gnome-base/gnome-keyring[pam] )
	mktemp? ( sys-auth/pam_mktemp )
	pam_krb5? (
		>=sys-libs/pam-${MIN_PAM_REQ}
		sys-auth/pam_krb5
	)
	caps? ( sys-libs/libcap[pam] )
	pam_ssh? ( sys-auth/pam_ssh )
	passwdqc? ( >=sys-auth/passwdqc-1.4.0-r1 )
	pwquality? ( dev-libs/libpwquality[pam] )
	selinux? ( sys-libs/pam[selinux] )
	sha512? ( >=sys-libs/pam-${MIN_PAM_REQ} )
	systemd? ( sys-apps/systemd[pam] )
"

BDEPEND="$(python_gen_any_dep '
		dev-python/jinja[${PYTHON_USEDEP}]
	')"

PATCHES=(
	"${FILESDIR}"/${PN}-20201013-consolekit.patch
)

python_check_deps() {
	python_has_version "dev-python/jinja[${PYTHON_USEDEP}]"
}

S="${WORKDIR}/${PN}-${P}"

src_configure() {
	${EPYTHON} ./${PN}.py \
		$(usex caps '--caps' '') \
		$(usex ck '--consolekit' '') \
		$(usex consolekit '--consolekit' '') \
		$(usex debug '--debug' '') \
		$(usex elogind '--elogind' '') \
		$(usex gnome-keyring '--gnome-keyring' '') \
		$(usex minimal '--minimal' '') \
		$(usex mktemp '--mktemp' '') \
		$(usex nullok '--nullok' '') \
		$(usex pam_krb5 '--krb5' '') \
		$(usex pam_ssh '--pam-ssh' '') \
		$(usex passwdqc '--passwdqc' '') \
		$(usex pwhistory '--pwhistory' '') \
		$(usex pwquality '--pwquality' '') \
		$(usex securetty '--securetty' '') \
		$(usex selinux '--selinux' '') \
		$(usex sha512 '--sha512' '') \
		$(usex systemd '--systemd' '') \
	|| die
}

src_test() { :; }

src_install() {
	local DOC_CONTENTS

	if use passwdqc; then
		DOC_CONTENTS="To amend the existing password policy please see the man 5 passwdqc.conf
				page and then edit the /etc/security/passwdqc.conf file"
	fi

	if use pwquality; then
		DOC_CONTENTS="To amend the existing password policy please see the man 5 pwquality.conf
				page and then edit the /etc/security/pwquality.conf file"
	fi

	{ use passwdqc || use pwquality; } && readme.gentoo_create_doc

	dopamd -r stack/.
}

pkg_postinst() {
	{ use passwdqc || use pwquality; } && readme.gentoo_print_elog
}
