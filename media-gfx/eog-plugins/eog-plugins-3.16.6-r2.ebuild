# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome2 python-single-r1

DESCRIPTION="Eye of GNOME plugins"
HOMEPAGE="https://wiki.gnome.org/Apps/EyeOfGnome/Plugins https://gitlab.gnome.org/GNOME/eog-plugins"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="+exif map picasa +python"
REQUIRED_USE="
	map? ( exif )
	python? ( ${PYTHON_REQUIRED_USE} )
"

RDEPEND="
	>=dev-libs/glib-2.38:2
	>=dev-libs/libpeas-0.7.4:=
	>=media-gfx/eog-3.15.90
	>=x11-libs/gtk+-3.14:3
	exif? ( >=media-libs/libexif-0.6.16 )
	map? (
		media-libs/libchamplain:0.12[gtk]
		>=media-libs/clutter-1.9.4:1.0
		>=media-libs/clutter-gtk-1.1.2:1.0 )
	picasa? ( >=dev-libs/libgdata-0.9.1:= )
	python? (
		${PYTHON_DEPS}
		>=dev-libs/glib-2.32:2[dbus]
		dev-libs/libpeas:=[gtk,python,${PYTHON_SINGLE_USEDEP}]
		$(python_gen_cond_dep '
			dev-python/pygobject:3[${PYTHON_USEDEP}]
		')
		gnome-base/gsettings-desktop-schemas
		media-gfx/eog[introspection]
		x11-libs/gtk+:3[introspection]
		x11-libs/pango[introspection] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/intltool-0.50.1
	sys-devel/gettext
	virtual/pkgconfig
"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local plugins="fit-to-width,send-by-mail,hide-titlebar,light-theme"
	use exif && plugins="${plugins},exif-display"
	use map && plugins="${plugins},map"
	use picasa && plugins="${plugins},postasa"
	use python && plugins="${plugins},slideshowshuffle,pythonconsole,fullscreenbg,export-to-folder,maximize-windows"
	gnome2_src_configure \
		$(use_enable python) \
		--with-plugins=${plugins}
}

src_install() {
	gnome2_src_install

	# From AppStream (the /usr/share/appdata location is deprecated):
	# 	https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html#spec-component-location
	# 	https://bugs.gentoo.org/709450
	mv "${ED}"/usr/share/{appdata,metainfo} || die

	find "${ED}" -type f -name "*.la" -delete || die
}
