# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit meson

DESCRIPTION="Linux D-Bus Message Broker"
HOMEPAGE="https://github.com/bus1/dbus-broker/wiki"
SRC_URI="https://github.com/bus1/dbus-broker/archive/v${PV}/${P}.tar.gz"

declare -Ag SUBPROJECTS=(
	[c-dvar]=ebcef28b0da11ec20250f2fa710130967ddd8fa9
	[c-ini]=f8336c98a74038a1104283fde284c5b82d6aef92
	[c-list]=ac7c831398219acd8d63038e866035a6f86f9e21
	[c-rbtree]=7624b79b26d020a796fe7c624a4f2d3340f3d66b
	[c-shquote]=80d4252f31c74785f0ec8c4578a26f1c16d5941e
	[c-stdaux]=ffa3dcc365331e31eb0c0f73ccd258e7a29a162a
	[c-utf8]=9017bab6cef301229e2295bdcb19476466065788
)
for sp in "${!SUBPROJECTS[@]}"; do
	commit=${SUBPROJECTS[${sp}]}
	SRC_URI+=" https://github.com/c-util/${sp}/archive/${commit}/${sp}-${commit}.tar.gz"
done
unset sp commit

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~*"

IUSE="audit doc elogind +launcher selinux systemd"
REQUIRED_USE="
	^^ ( elogind systemd )
"

DEPEND="
	audit? (
		>=sys-process/audit-2.7
		>=sys-libs/libcap-ng-0.6
	)
	launcher? (
		>=dev-libs/expat-2.2
		elogind? ( >=sys-auth/elogind-230:0= )
		systemd? ( >=sys-apps/systemd-230:0= )
	)
	selinux? ( sys-libs/libselinux )
"
RDEPEND="${DEPEND}
	launcher? ( sys-apps/dbus )"
BDEPEND="
	doc? ( dev-python/docutils )
	virtual/pkgconfig
"

src_prepare() {
	# From GNOME Without Systemd:
	# 	https://forums.gentoo.org/viewtopic-p-8267112.html#8267112
	eapply "${FILESDIR}"/${PN}-22-support-elogind.patch

	local sp commit
	for sp in "${!SUBPROJECTS[@]}"; do
		commit=${SUBPROJECTS[${sp}]}
		rmdir "subprojects/${sp}" || die
		mv "${WORKDIR}/${sp}-${commit}" "subprojects/${sp}" || die
	done
	default
}

src_configure() {
	local emesonargs=(
		-Daudit=$(usex audit true false)
		-Ddocs=$(usex doc true false)
		-Delogind=$(usex elogind true false)
		-Dlauncher=$(usex launcher true false)
		-Dselinux=$(usex selinux true false)
	)
	meson_src_configure
}
