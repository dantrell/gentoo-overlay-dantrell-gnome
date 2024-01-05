# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_10,3_11,3_12} )

inherit pam python-any-r1

DESCRIPTION="PAM base configuration files"
HOMEPAGE="https://github.com/gentoo/pambase"
SRC_URI="https://github.com/gentoo/pambase/archive/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

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

BDEPEND="$(python_gen_any_dep '
		dev-python/jinja[${PYTHON_USEDEP}]
	')"

PATCHES=(
	"${FILESDIR}"/${PN}-20200806-consolekit.patch
)

python_check_deps() {
	python_has_version "dev-python/jinja[${PYTHON_USEDEP}]"
}

S="${WORKDIR}/${PN}-${P}"

src_configure() {
	${EPYTHON} ./${PN}.py \
	$(usex caps '--libcap' '') \
	$(usex ck '--consolekit' '') \
	$(usex consolekit '--consolekit' '') \
	$(usex debug '--debug' '') \
	$(usex elogind '--elogind' '') \
	$(usex minimal '--minimal' '') \
	$(usex mktemp '--mktemp' '') \
	$(usex nullok '--nullok' '') \
	$(usex pam_krb5 '--krb5' '') \
	$(usex pam_ssh '--pam-ssh' '') \
	$(usex passwdqc '--passwdqc' '') \
	$(usex securetty '--securetty' '') \
	$(usex selinux '--selinux' '') \
	$(usex sha512 '--sha512' '') \
	$(usex systemd '--systemd' '')
}

src_test() { :; }

src_install() {
	dopamd -r stack/.
}
