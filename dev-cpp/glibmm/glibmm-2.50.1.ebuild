# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 multilib-minimal

DESCRIPTION="C++ interface for glib2"
HOMEPAGE="https://www.gtkmm.org https://gitlab.gnome.org/GNOME/glibmm"

LICENSE="LGPL-2.1+ GPL-2+" # GPL-2+ applies only to the build system
SLOT="2"
KEYWORDS="*"

IUSE="debug gtk-doc test"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/libsigc++:2=[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-2.9.1:2[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.50.0:2[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	gtk-doc? ( app-text/doxygen )
"
# dev-cpp/mm-common needed for eautoreconf

PATCHES=(
	# Fix build with GCC-8
	# https://bugs.gentoo.org/654776
	"${FILESDIR}"/${PN}-2.52.1-fix-threads-gobject.patch
)

src_prepare() {
	if ! use test; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' \
			-i Makefile.am Makefile.in || die "sed 1 failed"
	fi

	# don't build examples - we want to install example sources, not binaries
	sed 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' \
		-i Makefile.am Makefile.in || die "sed 2 failed"

	gnome2_src_prepare
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(use_enable debug debug-refcounting) \
		$(multilib_native_use_enable gtk-doc documentation) \
		--enable-deprecated-api
}

multilib_src_test() {
	cd tests
	default

	for i in */test; do
		${i} || die "Running tests failed at ${i}"
	done
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_install_all() {
	einstalldocs

	find examples -type d -name '.deps' -exec rm -rf {} \; 2>/dev/null
	find examples -type f -name 'Makefile*' -exec rm -f {} \; 2>/dev/null
	dodoc -r examples
}
