# Distributed under the terms of the GNU General Public License v2

EAPI="7"
CMAKE_MAKEFILE_GENERATOR="ninja"
VALA_MIN_API_VERSION="0.34"

inherit cmake git-r3 gnome2-utils vala xdg-utils

DESCRIPTION="Modern Jabber/XMPP Client using GTK+/Vala"
HOMEPAGE="https://dino.im"
EGIT_REPO_URI="https://github.com/dino/dino"
EGIT_COMMIT="45c0ac410433089cf973854c146b6b22df4a1a1c"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

IUSE="+gpg +http +omemo +notification-sound"

RDEPEND="
	dev-db/sqlite:3
	>=dev-libs/glib-2.38:2
	dev-libs/icu
	dev-libs/libgee:0.8
	net-libs/glib-networking
	=net-libs/libsignal-protocol-c-2.3.3
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-3.22:3
	x11-libs/pango
	gpg? ( app-crypt/gpgme:= )
	http? ( net-libs/libsoup:2.4 )
	omemo? (
		dev-libs/libgcrypt:0
		media-gfx/qrencode
	)
	notification-sound? ( media-libs/libcanberra:0[sound] )
"
DEPEND="
	$(vala_depend)
	${RDEPEND}
	sys-devel/gettext
"

src_prepare() {
	cmake_src_prepare
	vala_src_prepare
}

src_configure() {
	local disabled_plugins=(
		$(usex gpg "" "openpgp")
		$(usex omemo "" "omemo")
		$(usex http  "" "http-files")
	)
	local enabled_plugins=(
		$(usex notification-sound "notification-sound" "")
	)
	local mycmakeargs+=(
		"-DENABLED_PLUGINS=$(local IFS=";"; echo "${enabled_plugins[*]}")"
		"-DDISABLED_PLUGINS=$(local IFS=";"; echo "${disabled_plugins[*]}")"
		"-DVALA_EXECUTABLE=${VALAC}"
	)

	if has test ${FEATURES}; then
		mycmakeargs+=("-DBUILD_TESTS=yes")
	fi

	cmake_src_configure
}

src_test() {
	"${BUILD_DIR}"/xmpp-vala-test || die
}

update_caches() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postinst() {
	update_caches
}

pkg_postrm() {
	update_caches
}
