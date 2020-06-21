# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools git-r3

DESCRIPTION="IIO accelerometer sensor to input device proxy"
HOMEPAGE="https://developer.gnome.org/iio-sensor-proxy/1.0/"
EGIT_REPO_URI="https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/"
EGIT_COMMIT="b802147fd99f92692e91bfce92ce4131167642cf"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~*"

IUSE="elogind systemd"
REQUIRED_USE="
	^^ ( elogind systemd )
"

RDEPEND="
	elogind? ( >=sys-auth/elogind-233 )
	systemd? ( >=sys-apps/systemd-233 )
	dev-libs/libgudev
	app-misc/geoclue:*
"
DEPEND="
	${RDEPEND}
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
