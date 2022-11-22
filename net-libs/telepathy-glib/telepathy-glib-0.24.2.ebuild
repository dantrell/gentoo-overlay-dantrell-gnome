# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_REQ_USE="xml(+)"
PYTHON_COMPAT=( python{3_8,3_9,3_10,3_11} )

inherit gnome2 python-any-r1 vala virtualx

DESCRIPTION="GLib bindings for the Telepathy D-Bus protocol"
HOMEPAGE="https://telepathy.freedesktop.org/"
SRC_URI="https://telepathy.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="debug +introspection +vala"
REQUIRED_USE="vala? ( introspection )"

# Broken for a long time and upstream doesn't care
# https://bugs.freedesktop.org/show_bug.cgi?id=63212
RESTRICT="test"

RDEPEND="
	>=dev-libs/glib-2.36:2
	>=dev-libs/dbus-glib-0.90
	introspection? ( >=dev-libs/gobject-introspection-1.30:= )
"
DEPEND="${RDEPEND}
	vala? ( $(vala_depend) )
"
BDEPEND="
	${PYTHON_DEPS}
	dev-libs/libxslt
	dev-util/gtk-doc-am
	virtual/pkgconfig
"
# See bug 504744 for reference
PDEPEND="
	net-im/telepathy-mission-control
"

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--disable-installed-tests \
		$(use_enable debug backtrace) \
		$(use_enable debug debug-cache) \
		$(use_enable introspection) \
		$(use_enable vala vala-bindings)
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	# Needs dbus for tests (auto-launched)
	virtx emake -j1 check
}
