# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_REQ_USE="xml"
PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

inherit gnome2 distutils-r1

DESCRIPTION="A graphical diff and merge tool"
HOMEPAGE="http://meldmerge.org/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.36:2[dbus]
	dev-python/dbus-python[${PYTHON_USEDEP}]
	>=dev-python/pygobject-3.8:3[cairo,${PYTHON_USEDEP}]
	gnome-base/gsettings-desktop-schemas
	>=x11-libs/gtk+-3.14:3[introspection]
	>=x11-libs/gtksourceview-3.14:3.0[introspection]
	x11-themes/hicolor-icon-theme
"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/itstool
	sys-devel/gettext
"

src_repare() {
	# From GNOME:
	# 	https://git.gnome.org/browse/meld/commit/?id=3dddd7bbe122a6ffc2a2c78eeb5ef016f43cdf54
	# 	https://git.gnome.org/browse/meld/commit/?id=ff6f12bc870372b4409e9705c4b9f111e48b8c97
	# 	https://git.gnome.org/browse/meld/commit/?id=ca74bdca6afd82e04247a0783259393a3ab4bc50
	# 	https://git.gnome.org/browse/meld/commit/?id=a2f22b6503a0f1b07789b0180f6a99108e83962d
	eapply "${FILESDIR}"/${PN}-3.16.1-vc-add-darcs-to-list-of-loaded-plugins.patch
	eapply "${FILESDIR}"/${PN}-3.16.1-data-fix-unknown-text-in-meld-dark-style.patch
	eapply "${FILESDIR}"/${PN}-3.16.1-default-configuration-consider-osc-as-a-version-control-system.patch
	eapply "${FILESDIR}"/${PN}-3.16.1-filediff-meldbuffer-support-file-comparisons-from-pipes.patch
}

python_compile_all() {
	mydistutilsargs=( --no-update-icon-cache --no-compile-schemas )
}
