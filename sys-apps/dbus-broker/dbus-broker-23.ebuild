# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit meson

DESCRIPTION="Linux D-Bus Message Broker"
HOMEPAGE="https://github.com/bus1/dbus-broker/wiki"
SRC_URI="https://github.com/bus1/dbus-broker/archive/v${PV}/${P}.tar.gz"

declare -Ag SUBPROJECTS=(
	[c-dvar]=9e1a5b4363aaece7169df2b2852944a1434b2df5
	[c-ini]=43f379396a320940d0661c15780f618f84d29348
	[c-list]=b1cd4dbf967d73b24dfe6cc56aaf3fdd668692e3
	[c-rbtree]=fa97402c3faa18c2ddd8325eb66e2bd58a224477
	[c-shquote]=1d171fe52c23944c3c0be1f2603595f2488a9ff8
	[c-stdaux]=d6ecce8afbb7703e1469cc5e7a59a8bd32e2d4a4
	[c-utf8]=1f7e2ff1164bd2161cb480532b2b34cb2074bde1
)
for sp in "${!SUBPROJECTS[@]}"; do
	commit=${SUBPROJECTS[${sp}]}
	SRC_URI+=" https://github.com/c-util/${sp}/archive/${commit}/${sp}-${commit}.tar.gz"
done
unset sp commit

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

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
