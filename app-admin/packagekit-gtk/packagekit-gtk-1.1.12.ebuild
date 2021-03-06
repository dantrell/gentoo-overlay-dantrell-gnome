# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit xdg

MY_PN="PackageKit"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Gtk3 PackageKit backend library"
HOMEPAGE="https://www.freedesktop.org/software/PackageKit/"
SRC_URI="https://www.freedesktop.org/software/${MY_PN}/releases/${MY_P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.54:2
	media-libs/fontconfig
	>=x11-libs/gtk+-2:2
	>=x11-libs/gtk+-3:3
	x11-libs/pango
	~app-admin/packagekit-base-${PV}[introspection]
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S="${WORKDIR}/${MY_P}"

src_configure() {
	econf \
		--disable-bash-completion \
		--disable-command-not-found \
		--disable-cron \
		--disable-gstreamer-plugin \
		--disable-gtk-doc \
		--disable-local \
		--disable-man-pages \
		--disable-static \
		--disable-systemd \
		--disable-vala \
		--enable-dummy \
		--enable-gtk-module \
		--enable-introspection=yes \
		--localstatedir=/var
}

src_compile() {
	emake -C contrib/gtk-module
}

src_install() {
	emake -C contrib/gtk-module DESTDIR="${D}" install
	find "${D}" -name '*.la' -delete || die
}
