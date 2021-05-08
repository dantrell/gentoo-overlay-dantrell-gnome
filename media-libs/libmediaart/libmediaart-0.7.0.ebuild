# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit autotools gnome2 vala virtualx

DESCRIPTION="Manages, extracts and handles media art caches"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libmediaart"

LICENSE="LGPL-2.1+"
SLOT="1.0"
KEYWORDS="*"

IUSE="gtk +introspection qt4 qt5 vala"
REQUIRED_USE="
	?? ( gtk qt4 qt5 )
	vala? ( introspection )
"

RDEPEND="
	>=dev-libs/glib-2.38.0:2
	gtk? ( >=x11-libs/gdk-pixbuf-2.12:2 )
	introspection? ( >=dev-libs/gobject-introspection-1.30:= )
	qt4? ( dev-qt/qtgui:4 )
	qt5? ( dev-qt/qtgui:5 )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/gtk-doc-am-1.8
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	eapply "${FILESDIR}"/${PN}-0.7.0-qt5.patch #523122

	eautoreconf

	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local myconf=""
	if use qt4 ; then
		myconf="${myconf} --enable-qt --with-qt-version=4"
	elif use qt5 ; then
		myconf="${myconf} --enable-qt --with-qt-version=5"
	else
		myconf="${myconf} --disable-qt"
	fi

	gnome2_src_configure \
		--enable-unit-tests \
		$(use_enable gtk gdkpixbuf) \
		$(use_enable introspection) \
		$(use_enable vala) \
		${myconf}
}

src_test() {
	dbus-launch virtx emake check #513502
}
