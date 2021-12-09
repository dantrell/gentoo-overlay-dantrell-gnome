# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2-utils meson systemd udev xdg

DESCRIPTION="IIO sensors to D-Bus proxy"
HOMEPAGE="https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/"
SRC_URI="https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/-/archive/${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~*"

IUSE="elogind gtk-doc systemd test"
REQUIRED_USE="
	^^ ( elogind systemd )
"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.56:2
	test? ( x11-libs/gtk+:3 )
	dev-libs/gobject-introspection:=
	>=dev-libs/libgudev-237:=
	virtual/libudev:=
	virtual/udev
	elogind? ( >=sys-auth/elogind-233 )
	systemd? ( >=sys-apps/systemd-233 )
	>=sys-auth/polkit-0.91
	app-misc/geoclue:2.0
"
DEPEND="
	${RDEPEND}
	dev-util/gtk-doc-am
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-Dudevrulesdir="${EPREFIX}$(get_udevdir)/rules.d"
		-Dsystemdsystemunitdir="$(systemd_get_systemunitdir)"
		$(meson_use test gtk-tests)
		$(meson_use gtk-doc gtk_doc)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	if ! use systemd ; then
		# From Gentoo:
		# 	https://forums.gentoo.org/viewtopic-t-1115254.html
		newinitd "${FILESDIR}"/iio-sensor-proxy.initd iio-sensor-proxy
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
