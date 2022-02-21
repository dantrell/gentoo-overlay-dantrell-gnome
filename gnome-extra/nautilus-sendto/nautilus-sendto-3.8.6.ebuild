# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org meson

DESCRIPTION="A nautilus extension for sending files to locations"
HOMEPAGE="https://gitlab.gnome.org/Archive/nautilus-sendto"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND=">=dev-libs/glib-2.25.9:2"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.8
	dev-libs/appstream-glib
	virtual/pkgconfig
"

PATCHES=(
	# From Gentoo:
	# 	https://bugs.gentoo.org/831837
	"${FILESDIR}"/${PN}-3.34.0-fix-build-with-meson-0.61.patch
)

pkg_postinst() {
	if ! has_version "gnome-base/nautilus[sendto]"; then
		einfo "Note that ${CATEGORY}/${PN} is meant to be used as a helper by gnome-base/nautilus[sendto]"
	fi
}
