# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME_TARBALL_SUFFIX="bz2"
PYTHON_COMPAT=( python2_7 )

inherit autotools flag-o-matic gnome2 python-r1 virtualx

DESCRIPTION="GTK+2 bindings for Python"
HOMEPAGE="https://gitlab.gnome.org/Archive/pygtk"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="*"

IUSE="doc examples test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="!test? ( test )"

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.8:2
	>=x11-libs/pango-1.16
	>=dev-libs/atk-1.12
	>=x11-libs/gtk+-2.24:2
	>=dev-python/pycairo-1.0.2[${PYTHON_USEDEP}]
	>=dev-python/pygobject-2.26.8-r53:2[${PYTHON_USEDEP}]
	|| (
		>=dev-python/numpy-python2-1.16.5[${PYTHON_USEDEP}]
		<dev-python/numpy-1.17.4[${PYTHON_USEDEP}]
	)
	>=gnome-base/libglade-2.5:2.0
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? (
		dev-libs/libxslt
		>=app-text/docbook-xsl-stylesheets-1.70.1 )
"

PATCHES=(
	# Fix declaration of codegen in .pc
	"${FILESDIR}"/${PN}-2.13.0-fix-codegen-location.patch
	"${FILESDIR}"/${PN}-2.14.1-libdir-pc.patch
	# Fix leaks of Pango objects
	"${FILESDIR}"/${PN}-2.24.0-fix-leaks.patch
	# Fail when tests are failing, bug #391307
	"${FILESDIR}"/${PN}-2.24.0-test-fail.patch
	# Fix broken tests, https://bugzilla.gnome.org/show_bug.cgi?id=709304
	"${FILESDIR}"/${PN}-2.24.0-test_dialog.patch
	# Fix build on Darwin
	"${FILESDIR}"/${PN}-2.24.0-quartz-objc.patch
	# From GNOME:
	# 	https://gitlab.gnome.org/Archive/pygtk/-/commit/4aaa48eb80c6802aec6d03e5695d2a0ff20e0fc2
	"${FILESDIR}"/${PN}-2.24.1-drop-the-pangofont-find-shaper-virtual-method.patch
)

src_prepare() {
	default

	# Examples is handled "manually"
	sed -e 's/\(SUBDIRS = .* \)examples/\1/' \
		-i Makefile.am Makefile.in || die

	sed -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' \
		-i configure.ac || die #466968

	AT_M4DIR="m4" eautoreconf

	prepare_pygtk() {
		mkdir -p "${BUILD_DIR}" || die
	}
	python_foreach_impl prepare_pygtk
}

src_configure() {
	use hppa && append-flags -ffunction-sections
	configure_pygtk() {
		ECONF_SOURCE="${S}" gnome2_src_configure \
			$(use_enable doc docs) \
			--with-glade \
			--enable-thread
	}
	python_foreach_impl run_in_build_dir configure_pygtk
}

src_compile() {
	python_foreach_impl run_in_build_dir gnome2_src_compile
}

src_test() {
	# Let tests pass without permissions problems, bug #245103
	gnome2_environment_reset

	testing() {
		cd tests
		virtx emake check-local
	}
	python_foreach_impl run_in_build_dir testing
}

src_install() {
	dodoc AUTHORS ChangeLog INSTALL MAPPING NEWS README THREADS TODO

	if use examples; then
		rm examples/Makefile* || die
		dodoc -r examples
	fi

	python_foreach_impl run_in_build_dir gnome2_src_install
	find "${D}" -name '*.la' -type f -delete || die
}
