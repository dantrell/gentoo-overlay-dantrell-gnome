# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit meson xdg-utils

DESCRIPTION="Cross-distro effort for providing metadata for software in the Linux ecosystem"
HOMEPAGE="https://www.freedesktop.org/wiki/Distributions/AppStream/"
SRC_URI="https://www.freedesktop.org/software/appstream/releases/AppStream-${PV}.tar.xz"

LICENSE="LGPL-2.1+ GPL-2+"
# check as_api_level
SLOT="0/4"
KEYWORDS="*"

IUSE="apt doc +introspection qt5 test"

RESTRICT="test" # bug 691962

RDEPEND="
	dev-db/lmdb:=
	>=dev-libs/glib-2.58:2
	dev-libs/libxml2:2
	dev-libs/libyaml
	dev-libs/snowball-stemmer:=
	>=net-libs/libsoup-2.56:2.4
	introspection? ( >=dev-libs/gobject-introspection-1.56:= )
	qt5? ( dev-qt/qtcore:5 )
"
DEPEND="${RDEPEND}
	test? ( qt5? ( dev-qt/qttest:5 ) )
"
BDEPEND="
	dev-libs/appstream-glib
	dev-libs/libxslt
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	doc? ( app-text/docbook-xml-dtd:4.5 )
	test? ( dev-qt/linguist-tools:5 )
"

S="${WORKDIR}/AppStream-${PV}"

PATCHES=(
	"${FILESDIR}"/${PN}-0.12.11-no-highlight.js.patch
	"${FILESDIR}"/${PN}-0.12.11-qt-add-missing-provided-kindid-enum.patch
	"${FILESDIR}"/${PN}-0.12.11-disable-Werror-flags.patch # bug 733774
)

src_prepare() {
	default
	sed -e "/^as_doc_target_dir/s/appstream/${PF}/" -i docs/meson.build || die
	if ! use test; then
		sed -e "/^subdir.*tests/s/^/#DONT /" -i {,qt/}meson.build || die # bug 675944
	fi
	rm docs/html/static/js/HighlightJS.LICENSE \
		docs/html/static/js/highlight.min.js || die # incompatible license
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
		-Dinstall-docs=$(usex doc true false)
		-Dgir=$(usex introspection true false)
		-Dqt=$(usex qt5 true false)
	)

	meson_src_configure
}
