# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools bash-completion-r1 linux-info

DESCRIPTION="Unprivileged sandboxing tool, namespaces-powered chroot-like solution"
HOMEPAGE="https://github.com/projectatomic/bubblewrap"
SRC_URI="https://github.com/projectatomic/${PN}/releases/download/v${PV}/${P}.tar.xz"

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

# tests require root priviledge
RESTRICT="test"

pkg_setup() {
	if [[ ${MERGE_TYPE} != buildonly ]]; then
		use namespaces && CONFIG_CHECK="~UTS_NS ~IPC_NS ~USER_NS ~PID_NS ~NET_NS"
		CONFIG_CHECK+=" ~SECCOMP"
		linux-info_pkg_setup
	fi
}

src_prepare() {
	eapply_user
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--with-bash-completion-dir=$(get_bashcompdir)
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
