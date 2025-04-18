# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

MY_PN="chrome-gnome-shell"
MY_P="${MY_PN}-${PV}"

inherit cmake python-single-r1

DESCRIPTION="OS-native connector counterpart for GNOME Shell browser extension"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeShellIntegration"
SRC_URI="mirror://gnome/sources/${MY_PN}/${PV}/${MY_P}.tar.xz"

S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
	')
	gnome-base/gnome-shell
"
BDEPEND="
	app-misc/jq
	sys-apps/coreutils
"

src_configure() {
	local mycmakeargs=( -DBUILD_EXTENSION=OFF )
	cmake_src_configure
}

src_install() {
	cmake_src_install

	if [[ $(get_libdir) != "lib" && "${SYMLINK_LIB}" != yes ]]; then
		# Workaround www-client/firefox-bin manifests location
		# Bug: https://bugs.gentoo.org/643522
		insinto /usr/lib/mozilla/native-messaging-hosts
		doins "${ED}"/usr/$(get_libdir)/mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json
	fi
}

pkg_postinst() {
	elog "Please note that this package provides OS-native connector only."
	elog "You can install browser extension using link provided at"
	elog "https://extensions.gnome.org website."
}
