# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools bash-completion-r1 linux-info

DESCRIPTION="Unprivileged sandboxing tool, namespaces-powered chroot-like solution"
HOMEPAGE="https://github.com/projectatomic/bubblewrap"
SRC_URI="https://github.com/projectatomic/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="caps +man +namespaces selinux sudo +suid"
REQUIRED_USE="
	namespaces? ( suid )
	?? ( caps suid )
"

DEPEND="
	>=app-shells/bash-completion-2
	dev-libs/libxslt
	sys-libs/libseccomp
	caps? ( sys-libs/libcap )
	man? ( dev-libs/libxslt )
	selinux? ( >=sys-libs/libselinux-2.1.9 )
	sudo? ( app-admin/sudo )
"
RDEPEND="${DEPEND}"

pkg_pretend() {
	use namespaces && CONFIG_CHECK="~UTS_NS ~IPC_NS ~USER_NS ~PID_NS ~NET_NS"
	CONFIG_CHECK+=" ~SECCOMP"
	check_extra_config
}

src_prepare() {
	eapply_user
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable selinux)
		$(use_enable sudo)
	)
	if use caps; then
		myeconfargs+=( --with-priv-mode=cap )
	elif use suid; then
		myeconfargs+=( --with-priv-mode=setuid )
		if use namespaces; then
			myeconfargs+=( --enable-require-userns=yes )
		else
			myeconfargs+=( --enable-require-userns=no )
		fi
	else
		myeconfargs+=( --with-priv-mode=none )
		myeconfargs+=( --enable-require-userns=no )
	fi
	econf "${myeconfargs[@]}"
}

src_install() {
	make DESTDIR="${D}" install || die
}
