# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_6,3_7,3_8} )
VALA_MIN_API_VERSION="0.28"
VALA_USE_DEPEND="vapigen"

inherit gnome2 python-any-r1 vala virtualx

DESCRIPTION="A framework for easy media discovery and browsing"
HOMEPAGE="https://wiki.gnome.org/Projects/Grilo"

LICENSE="LGPL-2.1+"
SLOT="0.3/0" # subslot is libgrilo-0.3 soname suffix
KEYWORDS="*"

IUSE="gtk examples +introspection +network playlist test vala"
REQUIRED_USE="test? ( introspection )"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.44:2
	dev-libs/libxml2:2
	net-libs/liboauth
	gtk? ( >=x11-libs/gtk+-3:3 )
	introspection? ( >=dev-libs/gobject-introspection-0.9:= )
	network? ( >=net-libs/libsoup-2.41.3:2.4 )
	playlist? ( >=dev-libs/totem-pl-parser-3.4.1 )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.10
	>=dev-util/intltool-0.40
	virtual/pkgconfig
	vala? ( $(vala_depend) )
	test? (
		${PYTHON_DEPS}
		media-plugins/grilo-plugins:${SLOT%/*} )
"
# eautoreconf requires gnome-common

PATCHES=(
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/grilo/commit/60d135ef64f16671bb0ab4079ecbc59bdc32cbc7
	"${FILESDIR}"/${PN}-0.3.11-pls-support-totem-pl-parser-3-26-4.patch
)

pkg_setup() {
	# Python tests are currently commented out, but this is done via in exit(0) in testrunner.py
	# thus it still needs $PYTHON set up, which python-any-r1_pkg_setup will do for us
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	sed -e "s:GETTEXT_PACKAGE=grilo$:GETTEXT_PACKAGE=grilo-${SLOT%/*}:" \
		-i configure.ac configure || die "sed configure.ac configure failed"

	# Don't build examples
	sed -e '/SUBDIRS/s/examples//' \
		-i Makefile.am -i Makefile.in || die

	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	# --enable-debug only changes CFLAGS, useless for us
	gnome2_src_configure \
		--disable-static \
		--disable-debug \
		$(use_enable gtk test-ui) \
		$(use_enable introspection) \
		$(use_enable network grl-net) \
		$(use_enable playlist grl-pls) \
		$(use_enable test tests) \
		$(use_enable vala)
}

src_test() {
	# /net/throttling/small-delay can fail with parallel tests
	virtx emake -j1 check
}

src_install() {
	gnome2_src_install
	# Upstream made this conditional on gtk-doc build...
	DOC_MODULE_VERSION=${SLOT%/*} \
	emake -C doc install DESTDIR="${ED}"

	if use examples; then
		# Install example code
		insinto /usr/share/doc/${PF}/examples
		doins "${S}"/examples/*.c
	fi
}
