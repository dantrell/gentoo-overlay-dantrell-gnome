# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2

DESCRIPTION="A library that provides top functionality to applications"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libgtop"

LICENSE="GPL-2"
SLOT="2/10" # libgtop soname version
KEYWORDS="*"

IUSE="+introspection"

RDEPEND="
	>=dev-libs/glib-2.26:2
	introspection? ( >=dev-libs/gobject-introspection-0.6.7:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/gtk-doc-am-1.4
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
"

PATCHES=(
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/libgtop/commit/f5939dc69eac2929df8ff37c7babf03759cb94d5
	"${FILESDIR}"/${PN}-2.37.92-rework-code-to-get-rid-of-assigment.patch
)

src_configure() {
	gnome2_src_configure \
		--disable-static \
		$(use_enable introspection)
}
