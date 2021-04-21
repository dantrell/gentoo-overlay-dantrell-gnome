# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools bash-completion-r1 linux-info

DESCRIPTION="Unprivileged sandboxing tool, namespaces-powered chroot-like solution"
HOMEPAGE="https://github.com/containers/bubblewrap/"
SRC_URI="https://github.com/containers/${PN}/releases/download/v${PV}/${P}.tar.xz"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="caps +man +namespaces selinux sudo +suid"
REQUIRED_USE="
	namespaces? ( suid )
	?? ( caps suid )
"

# tests require root priviledge
RESTRICT="test"

RDEPEND="
	sys-libs/libseccomp
	caps? ( sys-libs/libcap )
	selinux? ( >=sys-libs/libselinux-2.1.9 )
	sudo? ( app-admin/sudo )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=app-shells/bash-completion-2
	app-text/docbook-xml-dtd:4.3
	app-text/docbook-xsl-stylesheets
	man? ( dev-libs/libxslt )
	virtual/pkgconfig
"

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
	)
	if use sudo; then
		myeconfargs+=( --enable-sudo )
	fi
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
