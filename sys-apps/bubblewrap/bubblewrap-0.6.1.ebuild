# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit linux-info meson

DESCRIPTION="Unprivileged sandboxing tool, namespaces-powered chroot-like solution"
HOMEPAGE="https://github.com/containers/bubblewrap/"
SRC_URI="https://github.com/containers/${PN}/releases/download/v${PV}/${P}.tar.xz"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE="selinux +suid"

# tests require root privileges
RESTRICT="test"

RDEPEND="
	sys-libs/libseccomp
	sys-libs/libcap
	selinux? ( >=sys-libs/libselinux-2.1.9 )
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-text/docbook-xml-dtd:4.3
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.6.1-clang-printf.patch
)

pkg_setup() {
	if [[ ${MERGE_TYPE} != buildonly ]]; then
		CONFIG_CHECK="~UTS_NS ~IPC_NS ~USER_NS ~PID_NS ~NET_NS"
		linux-info_pkg_setup
	fi
}

src_configure() {
	local emesonargs=(
		-Dbash_completion=enabled
		-Dman=enabled
		-Dzsh_completion=enabled
		$(meson_feature selinux)
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	if use suid; then
		chmod u+s "${ED}"/usr/bin/bwrap
	fi
}
