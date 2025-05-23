# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )
VALA_MIN_API_VERSION="0.28"
VALA_USE_DEPEND="vapigen"

inherit gnome2 python-any-r1 vala

DESCRIPTION="A framework for easy media discovery and browsing"
HOMEPAGE="https://wiki.gnome.org/Projects/Grilo"

LICENSE="LGPL-2.1+"
SLOT="0.2/1" # subslot is libgrilo-0.2 soname suffix
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
	>=dev-build/gtk-doc-am-1.10
	>=dev-util/intltool-0.40
	virtual/pkgconfig
	vala? ( $(vala_depend) )
	test? (
		${PYTHON_DEPS}
		media-plugins/grilo-plugins:${SLOT%/*} )
"
# eautoreconf requires gnome-common

pkg_setup() {
	# Python tests are currently commented out, but this is done via in exit(0) in testrunner.py
	# thus it still needs $PYTHON set up, which python-any-r1_pkg_setup will do for us
	use test && python-any-r1_pkg_setup
}

src_prepare() {
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

src_install() {
	gnome2_src_install
	# Upstream made this conditional on gtk-doc build...
	emake -C doc install DESTDIR="${ED}"

	if use examples; then
		# Install example code
		docinto examples
		dodoc "${S}"/examples/*.c
	fi
}
