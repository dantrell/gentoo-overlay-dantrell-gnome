# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org gnome2-utils meson vala virtualx xdg

DESCRIPTION="Simple low-level configuration system"
HOMEPAGE="https://wiki.gnome.org/Projects/dconf"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="gtk-doc"

RDEPEND="
	>=dev-libs/glib-2.44.0:2
	sys-apps/dbus
"
DEPEND="${RDEPEND}
	$(vala_depend)
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	dev-util/gdbus-codegen
	gtk-doc? ( >=dev-util/gtk-doc-1.15 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	<dev-util/meson-0.52
" # problem with meson-0.52+ https://gitlab.gnome.org/GNOME/dconf/issues/59

src_prepare() {
	xdg_src_prepare
	vala_src_prepare
}

src_configure() {
	local emesonargs=(
		-Denable-man=true
		$(meson_use gtk-doc enable-gtk-doc)
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}

src_install() {
	meson_src_install

	# GSettings backend may be one of: memory, gconf, dconf
	# Only dconf is really considered functional by upstream
	# must have it enabled over gconf if both are installed
	echo 'CONFIG_PROTECT_MASK="/etc/dconf"' >> 51dconf
	echo 'GSETTINGS_BACKEND="dconf"' >> 51dconf
	doenvd 51dconf
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_giomodule_cache_update

	# Kill existing dconf-service processes as recommended by upstream due to
	# possible changes in the dconf private dbus API.
	# dconf-service will be dbus-activated on next use.
	pids=$(pgrep -x dconf-service)
	if [[ $? == 0 ]]; then
		ebegin "Stopping dconf-service; it will automatically restart on demand"
		kill ${pids}
		eend $?
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_giomodule_cache_update
}
