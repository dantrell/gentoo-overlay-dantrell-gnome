# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
VALA_USE_DEPEND="vapigen"

inherit autotools gnome2 multilib-minimal vala

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg"

LICENSE="LGPL-2+"
SLOT="2"
KEYWORDS=""

IUSE="debug gtk-doc +introspection tools vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=dev-libs/glib-2.50.0:2[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.8.0[${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.16.0[glib,${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.38.0[${MULTILIB_USEDEP}]
	>=media-libs/harfbuzz-2.0:=[${MULTILIB_USEDEP}]
	>=dev-libs/libxml2-2.9.0:2[${MULTILIB_USEDEP}]
	>=x11-libs/gdk-pixbuf-2.20:2[introspection?,${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.10.8:= )
	tools? ( >=x11-libs/gtk+-3.10.0:3 )
"
# vala? ( $(vala_depend) ) removed because it causes the following circular dependency:
#
# dev-lang/vala
#  media-gfx/graphviz
#   gnome-base/librsvg
#    dev-lang/vala
#
# Ref. https://github.com/dantrell/gentoo-project-gnome-without-systemd#known-issues
DEPEND="${RDEPEND}
	>=virtual/rust-1.39.0[${MULTILIB_USEDEP}]
	dev-libs/gobject-introspection-common
	dev-libs/vala-common
	>=virtual/pkgconfig-0-r1
	gtk-doc? ( >=dev-util/gtk-doc-1.13 )
"
# >=gtk-doc-am-1.13, gobject-introspection-common, vala-common needed by eautoreconf

# Rust does not know the *-pc-* variants of target triples, but these ones.
CHOST_amd64=x86_64-unknown-linux-gnu
CHOST_x86=i686-unknown-linux-gnu
CHOST_arm64=aarch64-unknown-linux-gnu

src_prepare() {
	local build_dir

	use vala && vala_src_prepare

	# Work around issue where vala file is expected in local
	# directory instead of source directory.
	for v in $(multilib_get_enabled_abi_pairs); do
		build_dir="${S%%/}-${v}"
		mkdir -p "${build_dir}"
		cp -p "${S}/Rsvg-2.0-custom.vala" "${build_dir}"|| die
	done

	# call eapply_user (implicitly) before eautoreconf
	gnome2_src_prepare
	eautoreconf
}

multilib_src_configure() {
	local myconf=()

	# -Bsymbolic is not supported by the Darwin toolchain
	if [[ ${CHOST} == *-darwin* ]]; then
		myconf+=( --disable-Bsymbolic )
	fi

	# --disable-tools even when USE=tools; the tools/ subdirectory is useful
	# only for librsvg developers
	ECONF_SOURCE=${S} \
	cross_compiling=yes \
	gnome2_src_configure \
		--build=${CHOST_default} \
		--disable-static \
		--disable-tools \
		$(multilib_native_use_enable gtk-doc) \
		$(use_enable debug) \
		$(multilib_native_use_enable introspection) \
		$(multilib_native_use_enable vala) \
		--enable-pixbuf-loader \
		"${myconf[@]}"

	if multilib_is_native_abi; then
		ln -s "${S}"/doc/html doc/html || die
	fi
}

multilib_src_compile() {
	# causes segfault if set, see bug #411765
	unset __GL_NO_DSO_FINALIZER
	gnome2_src_compile
}

multilib_src_install() {
	gnome2_src_install
}

pkg_postinst() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	multilib_foreach_abi gnome2_pkg_postinst
}

pkg_postrm() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	multilib_foreach_abi gnome2_pkg_postrm
}
