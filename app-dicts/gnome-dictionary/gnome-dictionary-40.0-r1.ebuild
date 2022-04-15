# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic gnome.org gnome2-utils meson xdg

DESCRIPTION="Dictionary utility for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Dictionary"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="0" # does not provide a public libgdict-1.0.so anymore
KEYWORDS="*"

IUSE="ipv6"

DEPEND="
	>=dev-libs/glib-2.42:2
	>=x11-libs/gtk+-3.21.2:3
"
RDEPEND="${DEPEND}
	gnome-base/gsettings-desktop-schemas
"
BDEPEND="
	app-text/docbook-xsl-stylesheets
	app-text/docbook-xml-dtd:4.3
	dev-libs/libxslt
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	# From Gentoo:
	# 	https://bugs.gentoo.org/831555
	"${FILESDIR}"/${PN}-40.0-meson-0.61.patch
)

src_configure() {
	# Replicate what a release buildtype would set, as we use -Dbuildtype=plain
	append-cflags -DG_DISABLE_ASSERT -DG_DISABLE_CHECKS -DG_DISABLE_CAST_CHECKS

	local emesonargs=(
		$(meson_use ipv6 use_ipv6)
		-Dbuild_man=true
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
