# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME_ORG_MODULE="vala"

inherit autotools gnome2 vala

DESCRIPTION="A command line tool that generates Vala programming documentation"
HOMEPAGE="https://wiki.gnome.org/Projects/Valadoc"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~*"

IUSE=""

DEPEND="
	>=dev-lang/vala-0.19.0
	>=dev-libs/libgee-0.19.91
	>=media-gfx/graphviz-2.16
	>=dev-libs/glib-2.24.0:2
"
RDEPEND="${DEPEND}
	x11-libs/gdk-pixbuf:2
"

S="${WORKDIR}/${GNOME_ORG_MODULE}-${PV}"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/vala/commit/2b742fce82eb1326faaee3b2cc4ff993e701ef53
	# 	https://gitlab.gnome.org/GNOME/vala/commit/c63247759dca09d1a81dce6bc2e2992746d7c996
	eapply "${FILESDIR}"/${PN}-0.42.2-splice-valadoc.patch

	eautoreconf
	vala_src_prepare
	gnome2_src_prepare
}

src_install() {
	gnome2_src_install

	# Do not install files owned by Vala
	rm "${ED}"/usr/share/aclocal/vala.m4 || die
	rm "${ED}"/usr/share/vala/vapi/libvala-*.vapi || die
	rm "${ED}"/usr/lib64/libvala-*.so.0.0.0 || die
	rm "${ED}"/usr/lib64/pkgconfig/libvala-*.pc || die
	rm "${ED}"/usr/lib64/vala-*/libvalaccodegen.so || die
	rm "${ED}"/usr/include/vala-*/vala.h || die
	rm "${ED}"/usr/include/vala-*/valagee.h || die
	rm "${ED}"/usr/lib64/libvala-*.so || die
	rm "${ED}"/usr/lib64/libvala-*.so.0 || die
}
