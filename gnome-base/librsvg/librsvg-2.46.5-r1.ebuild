# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit autotools gnome2 multilib-minimal rust-toolchain vala

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg"

LICENSE="LGPL-2+"
SLOT="2"
KEYWORDS="*"

IUSE="gtk-doc +introspection vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=dev-libs/glib-2.48.0:2[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.8.0[${MULTILIB_USEDEP}]
	>=dev-libs/libcroco-0.6.1[${MULTILIB_USEDEP}]
	>=dev-libs/libxml2-2.9.0:2[${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.16.0[${MULTILIB_USEDEP}]
	>=x11-libs/gdk-pixbuf-2.20:2[introspection?,${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.38.0[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.10.8:= )
"
DEPEND="${RDEPEND}"
# vala? ( $(vala_depend) ) removed because it causes the following circular dependency:
#
# dev-lang/vala
#  media-gfx/graphviz
#   gnome-base/librsvg
#    dev-lang/vala
#
# Ref. https://github.com/dantrell/gentoo-project-gnome-without-systemd#known-issues
BDEPEND="
	>=virtual/rust-1.34.0[${MULTILIB_USEDEP}]
	dev-libs/gobject-introspection-common
	dev-libs/vala-common
	>=sys-devel/gettext-0.19.8
	>=dev-util/gtk-doc-am-1.13
	virtual/pkgconfig
	gtk-doc? ( >=dev-util/gtk-doc-1.13 )
	x11-libs/gdk-pixbuf
"
# >=gtk-doc-am-1.13, gobject-introspection-common, vala-common needed by eautoreconf

# Rust does not know the *-pc-* variants of target triples, but these ones.
CHOST_amd64=x86_64-unknown-linux-gnu
CHOST_x86=i686-unknown-linux-gnu
CHOST_arm64=aarch64-unknown-linux-gnu

QA_FLAGS_IGNORED="
	usr/bin/rsvg-convert
	usr/lib.*/librsvg.*
"

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
	local myconf=(
		--build=${CHOST_default}
		--disable-static
		--disable-tools  # only useful for librsvg developers
		$(multilib_native_use_enable gtk-doc)
		$(multilib_native_use_enable gtk-doc gtk-doc-html)
		$(multilib_native_use_enable introspection)
		$(multilib_native_use_enable vala)
		--enable-pixbuf-loader
	)

	# -Bsymbolic is not supported by the Darwin toolchain
	[[ ${CHOST} == *-darwin* ]] && myconf+=( --disable-Bsymbolic )

	if ! multilib_is_native_abi; then
		myconf+=(
			# Set the rust target, which can differ from CHOST
			RUST_TARGET="$(rust_abi)"
			# RUST_TARGET is only honored if cross_compiling, but non-native ABIs aren't cross as
			# far as C parts and configure auto-detection are concerned as CHOST equals CBUILD
			cross_compiling=yes
		)
	fi

	ECONF_SOURCE=${S} gnome2_src_configure "${myconf[@]}"

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

	if ! use gtk-doc ; then
		rm -r "${ED}"/usr/share/gtk-doc || die
	fi
}

multilib_src_install_all() {
	find "${ED}" -name '*.la' -delete || die
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
