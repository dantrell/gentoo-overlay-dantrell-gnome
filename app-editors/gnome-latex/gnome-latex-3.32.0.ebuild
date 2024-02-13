# Distributed under the terms of the GNU General Public License v2

EAPI="8"
VALA_MIN_API_VERSION="0.34"

inherit gnome2 vala

DESCRIPTION="Integrated LaTeX environment for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/GNOME-LaTeX https://gitlab.gnome.org/swilmet/gnome-latex"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection +latexmk rubber"

DEPEND="
	$(vala_depend)
	>=app-text/enchant-2.1.3:2=
	>=app-text/gspell-1.8:0=
	>=dev-libs/glib-2.50:2[dbus]
	>=dev-libs/libgee-0.10:0.8=
	gnome-base/gsettings-desktop-schemas
	>=x11-libs/gtk+-3.20:3
	>=x11-libs/gtksourceview-3.24:3.0=
	>=gui-libs/tepl-4.2:4
	x11-libs/gdk-pixbuf:2
	x11-libs/pango
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
"
RDEPEND="${DEPEND}
	virtual/latex-base
	x11-themes/hicolor-icon-theme
	latexmk? ( dev-tex/latexmk )
	rubber? ( dev-tex/rubber )

	!app-editors/latexila
"
BDEPEND="
	app-text/yelp-tools
	dev-util/gdbus-codegen
	>=dev-build/gtk-doc-am-1.14
	>=dev-util/intltool-0.50.1
	virtual/pkgconfig
"

src_prepare() {
	vala_setup
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(use_enable introspection)
}
