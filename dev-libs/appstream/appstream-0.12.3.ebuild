# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit meson xdg-utils

MY_PN="AppStream"

DESCRIPTION="Cross-distro effort for providing metadata for software in the Linux ecosystem"
HOMEPAGE="https://www.freedesktop.org/wiki/Distributions/AppStream/"
SRC_URI="https://www.freedesktop.org/software/appstream/releases/${MY_PN}-${PV}.tar.xz"

LICENSE="LGPL-2.1+ GPL-2+"
# check as_api_level
SLOT="0/4"
KEYWORDS="*"

IUSE="apt +introspection qt5 test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.46:2
	dev-libs/libxml2:2
	dev-libs/libyaml
	dev-libs/snowball-stemmer
	introspection? ( >=dev-libs/gobject-introspection-1.56:= )
	qt5? ( dev-qt/qtcore:5 )
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.5
	dev-libs/appstream-glib
	dev-util/itstool
	>=dev-util/meson-0.42.0
	>=sys-devel/gettext-0.19.8
	qt5? (
		dev-qt/linguist-tools:5
		test? ( dev-qt/qttest:5 )
	)
"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	default
	sed -e "/^as_doc_target_dir/s/appstream/${PF}/" -i docs/meson.build || die
}

src_configure() {
	xdg_environment_reset

	local emesonargs=(
		-Dapidocs=false
		-Ddocs=false
		-Dmaintainer=false
		-Dstemming=true
		-Dvapi=false
		-Dapt-support=$(usex apt true false)
		-Dgir=$(usex introspection true false)
		-Dqt=$(usex qt5 true false)
	)

	meson_src_configure
}
