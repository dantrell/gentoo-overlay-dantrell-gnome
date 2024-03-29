# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit flag-o-matic gnome2 multilib multilib-minimal

DESCRIPTION="Image loading library for GTK+"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gdk-pixbuf"

LICENSE="LGPL-2+"
SLOT="2"
KEYWORDS="*"

IUSE="X debug +introspection jpeg tiff test"

RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/glib-2.48.0:2[${MULTILIB_USEDEP}]
	>=media-libs/libpng-1.4:0=[${MULTILIB_USEDEP}]
	jpeg? ( media-libs/libjpeg-turbo:0=[${MULTILIB_USEDEP}] )
	tiff? ( >=media-libs/tiff-3.9.2:=[${MULTILIB_USEDEP}] )
	X? ( x11-libs/libX11[${MULTILIB_USEDEP}] )
	introspection? ( >=dev-libs/gobject-introspection-0.9.3:= )
"
# librsvg blocker is for the new pixbuf loader API, you lose icons otherwise
RDEPEND="${DEPEND}
	!<gnome-base/gail-1000
	!<gnome-base/librsvg-2.31.0
	!<x11-libs/gtk+-2.21.3:2
	!<x11-libs/gtk+-2.90.4:3
"
DEPEND="${DEPEND}
	>=dev-build/gtk-doc-am-1.20
	>=sys-devel/gettext-0.19
	virtual/pkgconfig
"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/gdk-pixbuf-query-loaders$(get_exeext)
)

src_prepare() {
	# From GNOME (do not run lowmem test on uclibc):
	# 	https://bugzilla.gnome.org/show_bug.cgi?id=756590
	# 	https://bugzilla.gnome.org/show_bug.cgi?id=788770
	eapply "${FILESDIR}"/${PN}-2.32.3-fix-lowmem-uclibc.patch

	# This will avoid polluting the pkg-config file with versioned libpng,
	# which is causing problems with libpng14 -> libpng15 upgrade
	# See upstream bug #667068
	# First check that the pattern is present, to catch upstream changes on bumps,
	# because sed doesn't return failure code if it doesn't do any replacements
	grep -q  'l in libpng16' configure || die "libpng check order has changed upstream"
	sed -e 's:l in libpng16:l in libpng libpng16:' -i configure || die
	[[ ${CHOST} == *-solaris* ]] && append-libs intl

	gnome2_src_prepare
}

multilib_src_configure() {
	# png always on to display icons
	ECONF_SOURCE="${S}" \
	gnome2_src_configure \
		$(usex debug --enable-debug=yes "") \
		$(use_with jpeg libjpeg) \
		--without-libjasper \
		$(use_with tiff libtiff) \
		$(multilib_native_use_enable introspection) \
		$(use_with X x11) \
		--with-libpng

	# work-around gtk-doc out-of-source brokedness
	if multilib_is_native_abi; then
		ln -s "${S}"/docs/reference/${PN}/html docs/reference/${PN}/html || die
	fi
}

multilib_src_install() {
	# Parallel install fails when no gdk-pixbuf is already installed, bug #481372
	MAKEOPTS="${MAKEOPTS} -j1" gnome2_src_install
}

pkg_preinst() {
	gnome2_pkg_preinst

	multilib_pkg_preinst() {
		# Make sure loaders.cache belongs to gdk-pixbuf alone
		local cache="usr/$(get_libdir)/${PN}-2.0/2.10.0/loaders.cache"

		if [[ -e ${EROOT}${cache} ]]; then
			cp "${EROOT}"${cache} "${ED}"/${cache} || die
		else
			touch "${ED}"/${cache} || die
		fi
	}

	multilib_foreach_abi multilib_pkg_preinst
}

pkg_postinst() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER

	multilib_foreach_abi gnome2_pkg_postinst

	# Migration snippet for when this was handled by gtk+
	if [ -e "${EROOT}"usr/lib/gtk-2.0/2.*/loaders ]; then
		elog "You need to rebuild ebuilds that installed into" "${EROOT}"usr/lib/gtk-2.0/2.*/loaders
		elog "to do that you can use qfile from portage-utils:"
		elog "emerge -va1 \$(qfile -qC ${EPREFIX}/usr/lib/gtk-2.0/2.*/loaders)"
	fi
}

pkg_postrm() {
	gnome2_pkg_postrm

	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		rm -f "${EROOT}"usr/lib*/${PN}-2.0/2.10.0/loaders.cache
	fi
}
