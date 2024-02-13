# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GNOME2_LA_PUNT="yes"
GNOME_TARBALL_SUFFIX="bz2"

inherit gnome2

DESCRIPTION="GNOME CORBA framework"
HOMEPAGE="https://developer.gnome.org/libbonobo/stable/"

LICENSE="LGPL-2.1 GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="debug examples test"

# Tests are broken in several ways as reported in bug #288689 and upstream
# doesn't take care since libbonobo is deprecated.
RESTRICT="test"

RDEPEND="
	>=dev-libs/glib-2.14:2
	>=gnome-base/orbit-2.14.0
	>=dev-libs/libxml2-2.4.20:2
	>=sys-apps/dbus-1.0.0
	>=dev-libs/dbus-glib-0.74
	>=dev-libs/popt-1.5
	!gnome-base/bonobo-activation
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/gtk-doc-am
	app-alternatives/yacc
	sys-devel/flex
	x11-apps/xrdb
	virtual/pkgconfig
	>=dev-util/intltool-0.35
"

src_prepare() {
	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in || die

	if ! use test; then
		# don't waste time building tests, bug #226223
		sed 's/tests//' -i Makefile.am Makefile.in || die
	fi

	if ! use examples; then
		sed 's/samples//' -i Makefile.am Makefile.in || die
	fi

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable debug bonobo-activation-debug)
}

src_test() {
	# Pass tests with FEATURES userpriv, see bug #288689
	unset ORBIT_SOCKETDIR
	emake check
}
