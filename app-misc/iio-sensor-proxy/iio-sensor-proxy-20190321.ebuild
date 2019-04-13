# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools git-r3

DESCRIPTION="IIO accelerometer sensor to input device proxy"
HOMEPAGE="https://developer.gnome.org/iio-sensor-proxy/1.0/"
EGIT_REPO_URI="https://github.com/hadess/iio-sensor-proxy"
EGIT_COMMIT="25cb8f3f179e7286464c149268d65e5f6fd2b9fd"

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
	virtual/libgudev
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
