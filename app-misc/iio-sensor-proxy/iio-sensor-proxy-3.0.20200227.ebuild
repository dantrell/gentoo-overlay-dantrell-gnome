# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools git-r3

DESCRIPTION="IIO sensors to D-Bus proxy"
HOMEPAGE="https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/"
EGIT_REPO_URI="https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/"
EGIT_COMMIT="ba7a80dc933216ea96a72bbe7a6dbb06752a6493"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="*"

IUSE="elogind systemd"
REQUIRED_USE="
	^^ ( elogind systemd )
"

RDEPEND="
	>=dev-libs/glib-2.56:2
	dev-libs/gobject-introspection:=
	>=dev-libs/libgudev-237:=
	virtual/libudev:=
	virtual/udev
	elogind? ( >=sys-auth/elogind-233 )
	systemd? ( >=sys-apps/systemd-233 )
	>=sys-auth/polkit-0.91
	app-misc/geoclue:2
"
DEPEND="
	${RDEPEND}
	dev-util/gtk-doc-am
	virtual/pkgconfig
"

src_prepare() {
	eapply "${FILESDIR}"/${PN}-20180514-support-elogind.patch

	eapply_user

	eautoreconf
}

src_configure() {
	local econfargs=(
		--disable-Werror
		--disable-gtk-tests
	)
	econf "${econfargs[@]}"
}
