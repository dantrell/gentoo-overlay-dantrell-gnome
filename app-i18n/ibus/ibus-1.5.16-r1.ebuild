# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_10,3_11,3_12} )
VALA_USE_DEPEND="vapigen"
VALA_MIN_API_VERSION="0.34"
VALA_MAX_API_VERSION="0.36"

inherit autotools bash-completion-r1 gnome2-utils ltprune python-r1 vala virtualx

DESCRIPTION="Intelligent Input Bus for Linux / Unix OS"
HOMEPAGE="https://github.com/ibus/ibus/wiki"
SRC_URI="https://github.com/${PN}/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="+X +emoji gconf +gtk +gtk2 +gtk3 +introspection kde +libnotify nls +python test vala wayland"
REQUIRED_USE="emoji? ( gtk )
	gtk2? ( gtk )
	gtk3? ( gtk )
	kde? ( gtk )
	libnotify? ( gtk )
	python? (
		${PYTHON_REQUIRED_USE}
		gtk
		introspection
	)
	test? ( gtk )
	vala? ( introspection )"

RESTRICT="!test? ( test )"

CDEPEND="app-text/iso-codes
	dev-libs/glib:2
	gnome-base/dconf
	gnome-base/librsvg:2
	sys-apps/dbus[X?]
	X? (
		x11-libs/libX11
		!gtk3? ( x11-libs/gtk+:2 )
	)
	gconf? ( gnome-base/gconf:2 )
	gtk? (
		x11-libs/libX11
		x11-libs/libXi
		gtk2? ( x11-libs/gtk+:2 )
		gtk3? ( x11-libs/gtk+:3 )
	)
	introspection? ( dev-libs/gobject-introspection:= )
	kde? ( dev-qt/qtgui:5 )
	libnotify? ( x11-libs/libnotify )
	nls? ( virtual/libintl )
	python? (
		${PYTHON_DEPS}
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	)
	wayland? (
		dev-libs/wayland
		x11-libs/libxkbcommon
	)"
RDEPEND="${CDEPEND}
	python? (
		gtk? (
			x11-libs/gtk+:3[introspection]
		)
	)"
DEPEND="${CDEPEND}
	$(vala_depend)
	dev-util/intltool
	virtual/pkgconfig
	emoji? (
		app-i18n/unicode-cldr
		app-i18n/unicode-emoji
	)
	nls? ( sys-devel/gettext )"

src_prepare() {
	# From IBus:
	# 	https://github.com/ibus/ibus/commits/master
	eapply "${FILESDIR}"/1.5.17
	eapply "${FILESDIR}"/1.5.18

	vala_src_prepare --ignore-use
	if ! use emoji; then
		touch \
			tools/main.vala \
			ui/gtk3/panel.vala
	fi
	if ! use kde; then
		touch ui/gtk3/panel.vala
	fi
	if ! use libnotify; then
		touch ui/gtk3/panel.vala
	fi
	# for multiple Python implementations
	sed -i "s/^\(PYGOBJECT_DIR =\).*/\1/" bindings/Makefile.am
	# fix for parallel install
	sed -i \
		-e "/^py2_compile/,/^$/d" \
		-e "/^install-data-hook/,/^$/d" \
		bindings/pygobject/Makefile.am
	# require user interaction
	sed -i "/^TESTS += ibus-compose/d" src/tests/Makefile.am

	sed -i "/^bash_completion/d" tools/Makefile.am

	default
	eautoreconf
}

src_configure() {
	local unicodedir="${EPREFIX}"/usr/share/unicode
	local python_conf=()
	if use python; then
		python_setup
		python_conf+=(
			$(use_enable gtk setup)
			--with-python=${EPYTHON}
		)
	else
		python_conf+=( --disable-setup )
	fi

	econf \
		$(use_enable X xim) \
		$(use_enable emoji emoji-dict) \
		$(use_with emoji unicode-emoji-dir "${unicodedir}"/emoji) \
		$(use_with emoji emoji-annotation-dir "${unicodedir}"/cldr/common/annotations) \
		$(use_enable gconf) \
		$(use_enable gtk ui) \
		$(use_enable gtk2) \
		$(use_enable gtk3) \
		$(use_enable introspection) \
		$(use_enable kde appindicator) \
		$(use_enable libnotify) \
		$(use_enable nls) \
		$(use_enable test tests) \
		$(use_enable vala) \
		$(use_enable wayland) \
		"${python_conf[@]}"
}

src_test() {
	virtx emake -j1 check
}

src_install() {
	default
	prune_libtool_files --modules

	if use python; then
		python_install() {
			emake -C bindings/pygobject \
				pyoverridesdir="$(${EPYTHON} -c 'import gi; print(gi._overridesdir)')" \
				DESTDIR="${D}" \
				install
		}
		python_foreach_impl python_install
	fi

	keepdir /usr/share/ibus/engine

	newbashcomp tools/${PN}.bash ${PN}

	insinto /etc/X11/xinit/xinput.d
	newins xinput-${PN} ${PN}.conf
}

pkg_preinst() {
	use gconf && gnome2_gconf_savelist
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	use gconf && gnome2_gconf_install
	use gtk2 && gnome2_query_immodules_gtk2
	use gtk3 && gnome2_query_immodules_gtk3
	gnome2_icon_cache_update
	gnome2_schemas_update
	dconf update
}

pkg_postrm() {
	use gtk2 && gnome2_query_immodules_gtk2
	use gtk3 && gnome2_query_immodules_gtk3
	gnome2_icon_cache_update
	gnome2_schemas_update
}
