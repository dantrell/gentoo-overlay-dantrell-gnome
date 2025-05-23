# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit autotools python-any-r1 readme.gentoo-r1 xdg-utils

DESCRIPTION="SPICE server"
HOMEPAGE="https://www.spice-space.org/"
SRC_URI="https://www.spice-space.org/download/releases/spice-server/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="gstreamer lz4 sasl smartcard static-libs"

# the libspice-server only uses the headers of libcacard
RDEPEND="dev-lang/orc[static-libs(+)?]
	>=dev-libs/glib-2.22:2[static-libs(+)?]
	dev-libs/openssl:0=[static-libs(+)?]
	media-libs/opus[static-libs(+)?]
	media-libs/libjpeg-turbo:0=[static-libs(+)?]
	sys-libs/zlib[static-libs(+)?]
	>=x11-libs/pixman-0.17.7[static-libs(+)?]
	lz4? ( app-arch/lz4:0=[static-libs(+)?] )
	smartcard? ( >=app-emulation/libcacard-0.1.2 )
	sasl? ( dev-libs/cyrus-sasl[static-libs(+)?] )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)"
DEPEND="${RDEPEND}
	>=app-emulation/spice-protocol-0.12.13
	<app-emulation/spice-protocol-0.13.0
	smartcard? ( app-emulation/qemu[smartcard] )"
BDEPEND="${PYTHON_DEPS}
	virtual/pkgconfig
	$(python_gen_any_dep '
		>=dev-python/pyparsing-1.5.6-r2[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
	')"

PATCHES=(
	"${FILESDIR}"/${PN}-0.14.0-openssl1.1_fix.patch
	"${FILESDIR}"/${PN}-0.14.0-fix-flexible-array-buffer-overflow.patch
)

python_check_deps() {
	python_has_version ">=dev-python/pyparsing-1.5.6-r2[${PYTHON_USEDEP}]"
	python_has_version "dev-python/six[${PYTHON_USEDEP}]"
}

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	# Prevent sandbox violations, bug #586560
	# https://bugzilla.gnome.org/show_bug.cgi?id=744134
	# https://bugzilla.gnome.org/show_bug.cgi?id=744135
	addpredict /dev

	xdg_environment_reset

	local myconf=(
		$(use_enable static-libs static)
		$(use_enable lz4)
		$(use_with sasl)
		$(use_enable smartcard)
		--enable-gstreamer=$(usex gstreamer "1.0" "no")
		--disable-celt051
	)

	econf "${myconf[@]}"
}

src_compile() {
	# Prevent sandbox violations, bug #586560
	# https://bugzilla.gnome.org/show_bug.cgi?id=744134
	# https://bugzilla.gnome.org/show_bug.cgi?id=744135
	addpredict /dev

	default
}

src_install() {
	default
	use static-libs || find "${D}" -name '*.la' -type f -delete || die
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
