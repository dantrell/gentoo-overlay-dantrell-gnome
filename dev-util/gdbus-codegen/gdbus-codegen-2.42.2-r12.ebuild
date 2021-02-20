# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME_ORG_MODULE="glib"
PYTHON_COMPAT=( python{3_6,3_7,3_8,3_9} )
PYTHON_REQ_USE="xml"

inherit gnome.org distutils-r1

DESCRIPTION="GDBus code and documentation generator"
HOMEPAGE="https://www.gtk.org/"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS=""

IUSE=""

RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}"

# To prevent circular dependencies with glib[test]
PDEPEND=">=dev-libs/glib-${PV}:2"

S="${WORKDIR}/glib-${PV}/gio/gdbus-2.0/codegen"

python_prepare_all() {
	eapply -p4 "${FILESDIR}"/${PN}-2.40.0-sitedir.patch
	distutils-r1_python_prepare_all

	sed -e 's:#!@PYTHON@:#!/usr/bin/env python:' gdbus-codegen.in > gdbus-codegen || die
	cp "${FILESDIR}"/setup.py-2.32.4 setup.py || die "cp failed"
	sed -e "s/@PV@/${PV}/" -i setup.py || die "sed setup.py failed"
}

src_test() {
	einfo "Skipping tests. This package is tested by dev-libs/glib"
	einfo "when merged with FEATURES=test"
}

python_install_all() {
	distutils-r1_python_install_all # no-op, but prevents QA warning
	doman "${WORKDIR}/glib-${PV}/docs/reference/gio/gdbus-codegen.1"
}
