# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit bash-completion-r1 gnome2 vala virtualx

DESCRIPTION="Simple low-level configuration system"
HOMEPAGE="https://wiki.gnome.org/Projects/dconf"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="test"

RDEPEND="
	>=dev-libs/glib-2.39.1:2
	sys-apps/dbus
"
DEPEND="${RDEPEND}
	$(vala_depend)
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.15
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-gcov \
		--enable-man
}

src_test() {
	virtx emake check
}

src_install() {
	gnome2_src_install

	# GSettings backend may be one of: memory, gconf, dconf
	# Only dconf is really considered functional by upstream
	# must have it enabled over gconf if both are installed
	echo 'CONFIG_PROTECT_MASK="/etc/dconf"' >> 51dconf
	echo 'GSETTINGS_BACKEND="dconf"' >> 51dconf
	doenvd 51dconf

	# Install bash-completion file properly to the system
	rm -rv "${ED}usr/share/bash-completion" || die
	dobashcomp "${S}/bin/completion/dconf"
}

pkg_postinst() {
	gnome2_pkg_postinst
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
