# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_8,3_9,3_10,3_11} )

inherit gnome2 multibuild python-r1

DESCRIPTION="A collection of documentation utilities for the Gnome project"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeDocUtils"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/libxml2-2.6.12:2[python,${PYTHON_USEDEP}]
	>=dev-libs/libxslt-1.1.8
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.4
	app-text/scrollkeeper-dtd
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/awk
	virtual/pkgconfig
"
# dev-libs/glib needed for eautofoo, bug #255114.

# If there is a need to reintroduce eautomake or eautoreconf, make sure
# to AT_M4DIR="tools m4", bug #224609 (m4 removes glib build time dep)

src_prepare() {
	# Stop build from relying on installed package
	eapply "${FILESDIR}"/${P}-fix-out-of-tree-build.patch
	eapply "${FILESDIR}"/${P}-python3.patch

	gnome2_src_prepare

	# Leave shebang alone
	sed -e '/s+^#!.*python.*+#/d' \
		-i xml2po/xml2po/Makefile.{am,in} || die

	python_prepare() {
		mkdir -p "${BUILD_DIR}"
	}
	python_foreach_impl python_prepare
}

src_configure() {
	ECONF_SOURCE="${S}" python_foreach_impl run_in_build_dir gnome2_src_configure
}

src_compile() {
	MAKEOPTS="${MAKEOPTS} -j1" python_foreach_impl run_in_build_dir gnome2_src_compile #574282
}

src_test() {
	python_foreach_impl run_in_build_dir default
}

src_install() {
	python_foreach_impl run_in_build_dir gnome2_src_install
	python_foreach_impl run_in_build_dir python_optimize
	python_replicate_script "${ED}"/usr/bin/xml2po
}
