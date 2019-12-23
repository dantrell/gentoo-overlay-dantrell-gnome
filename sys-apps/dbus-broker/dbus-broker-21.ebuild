# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit meson

DESCRIPTION="Linux D-Bus Message Broker"
HOMEPAGE="https://github.com/bus1/dbus-broker/wiki"
SRC_URI="https://github.com/bus1/dbus-broker/archive/v${PV}/${P}.tar.gz"

declare -Ag SUBPROJECTS=(
	[c-dvar]=7c0833f9cae446163077b204b2296287bbee7c67
	[c-ini]=847c55f5b3d33baa47af9a1286175d58b34f91d5
	[c-list]=2e4b605c6217cd3c8a1ef773f82f5cc329ba650d
	[c-rbtree]=b46392d25de7a7bab67d48ef18bf8350b429cff5
	[c-shquote]=34e1e25299fb82ab9fd0c8bfd8a66010ead1497b
	[c-stdaux]=11930d259212605a15430523472ef54e0c7654ee
	[c-utf8]=34f5df0f4b28fc7ea6747680a432e666047082e4
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
	dev-python/docutils
	virtual/pkgconfig
"

src_prepare() {
	# From GNOME Without Systemd:
	# 	https://forums.gentoo.org/viewtopic-p-8267112.html#8267112
	eapply "${FILESDIR}"/${PN}-21-support-elogind.patch

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
