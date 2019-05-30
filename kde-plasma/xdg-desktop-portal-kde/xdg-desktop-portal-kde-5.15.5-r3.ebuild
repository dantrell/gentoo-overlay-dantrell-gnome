# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VIRTUALX_REQUIRED="test"

inherit cmake-utils kde5

DESCRIPTION="Backend implementation for xdg-desktop-portal that is using Qt/KDE Frameworks"

LICENSE="LGPL-2+"
KEYWORDS="*"

IUSE="pipewire"

# TODO: Needed for screencast portal
# 	dev-libs/glib:2
# 	media-libs/libepoxy
# 	media-libs/mesa[gbm]
COMMON_DEPEND="
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep kio)
	$(add_frameworks_dep knotifications)
	$(add_frameworks_dep kwidgetsaddons)
	$(add_qt_dep qtdbus)
	$(add_qt_dep qtgui)
	$(add_qt_dep qtprintsupport 'cups')
	$(add_qt_dep qtwidgets)
"
DEPEND="${COMMON_DEPEND}
	$(add_frameworks_dep kwayland)
	$(add_qt_dep qtconcurrent)
"
RDEPEND="${COMMON_DEPEND}
	sys-apps/xdg-desktop-portal
	pipewire? ( media-video/pipewire )
"

PATCHES=(
	"${FILESDIR}"/${PN}-5.15.5-appchooser.patch
	# From Gentoo:
	# 	https://bugs.gentoo.org/667014
	"${FILESDIR}"/${PN}-5.15.5-pipewire-work-branch-compat.patch
	# From Gentoo:
	# 	https://forums.gentoo.org/viewtopic-p-8339276.html#8339276
	"${FILESDIR}"/${PN}-5.15.5-optional-pipewire.patch
)

src_configure() {
	local mycmakeargs=(
		-DUSE_PIPEWIRE=$(usex pipewire)
	)

	cmake-utils_src_configure
}
