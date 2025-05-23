# Distributed under the terms of the GNU General Public License v2

EAPI="7"
GST_ORG_MODULE="gst-plugins-bad"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gstreamer-meson python-any-r1

DESCRIPTION="Less plugins for GStreamer"
HOMEPAGE="https://gstreamer.freedesktop.org/"

LICENSE="LGPL-2"
KEYWORDS="*"

# TODO: egl and gtk IUSE only for transition
IUSE="X bzip2 +egl gles2 gtk +introspection +opengl +orc vnc wayland qsv" # Keep default IUSE mirrored with gst-plugins-base where relevant

# FIXME: gstharness.c:889:gst_harness_new_with_padnames: assertion failed: (element != NULL)
RESTRICT="test"

# X11 is automagic for now, upstream #709530 - only used by librfb USE=vnc plugin
# We mirror opengl/gles2 from -base to ensure no automagic openglmixers plugin (with "opengl?" it'd still get built with USE=-opengl here)
# FIXME	gtk? ( >=media-plugins/gst-plugins-gtk-${PV}:${SLOT}[${MULTILIB_USEDEP}] )
RDEPEND="
	!media-plugins/gst-transcoder
	>=media-libs/gstreamer-${PV}:${SLOT}[${MULTILIB_USEDEP},introspection?]
	>=media-libs/gst-plugins-base-${PV}:${SLOT}[${MULTILIB_USEDEP},egl?,introspection?,gles2=,opengl=]
	introspection? ( >=dev-libs/gobject-introspection-1.31.1:= )

	bzip2? ( >=app-arch/bzip2-1.0.6-r4[${MULTILIB_USEDEP}] )
	vnc? ( X? ( x11-libs/libX11[${MULTILIB_USEDEP}] ) )
	wayland? (
		>=dev-libs/wayland-1.4.0[${MULTILIB_USEDEP}]
		>=x11-libs/libdrm-2.4.55[${MULTILIB_USEDEP}]
		>=dev-libs/wayland-protocols-1.15
	)

	orc? ( >=dev-lang/orc-0.4.17[${MULTILIB_USEDEP}] )

	qsv? ( media-libs/oneVPL[wayland?,X?] )
"

DEPEND="${RDEPEND}"

BDEPEND="
	${PYTHON_DEPS}"

DOCS=( AUTHORS ChangeLog NEWS README.md RELEASE )

# Fixes backported to 1.20.1, to be removed in 1.20.2+
PATCHES=(
)

src_prepare() {
	default
	addpredict /dev # Prevent sandbox violations bug #570624
}

multilib_src_configure() {
	GST_PLUGINS_NOAUTO="shm ipcpipeline librfb msdk hls"

	local emesonargs=(
		-Dshm=enabled
		-Dipcpipeline=enabled
		-Dhls=disabled
		$(meson_feature vnc librfb)

		$(meson_feature wayland)
	)

	# Quick Sync Video is amd64 native only
	if use qsv && multilib_is_native_abi; then
		emesonargs+=(
			-Dmsdk=enabled
			-Dmfx_api=oneVPL
		)
	else
		emesonargs+=( -Dmsdk=disabled )
	fi

	if use opengl || use gles2; then
		myconf+=( -Dgl=enabled )
	else
		myconf+=( -Dgl=disabled )
	fi

	gstreamer_multilib_src_configure
}

multilib_src_test() {
	# Tests are slower than upstream expects
	CK_DEFAULT_TIMEOUT=300 gstreamer_multilib_src_test
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}
