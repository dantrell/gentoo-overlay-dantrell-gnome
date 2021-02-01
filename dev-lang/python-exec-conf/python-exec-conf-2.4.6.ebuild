# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit python-utils-r1

MY_P=${P/-conf}
DESCRIPTION="Configuration file for dev-lang/python-exec"
HOMEPAGE="https://github.com/mgorny/python-exec/"
SRC_URI="https://github.com/mgorny/python-exec/releases/download/v${PV}/${MY_P}.tar.bz2"

S=${WORKDIR}/${MY_P}

LICENSE="BSD-2"
SLOT="2"
KEYWORDS="~*"

# Internal Python project hack.  Do not copy it.  Ever.
IUSE="${_PYTHON_ALL_IMPLS[@]/#/python_targets_}"

RDEPEND="!<dev-lang/python-exec-2.4.6-r4"

src_configure() {
	:
}

src_install() {
	local pyimpls=() i EPYTHON
	for i in "${_PYTHON_ALL_IMPLS[@]}"; do
		if use "python_targets_${i}"; then
			_python_export "${i}" EPYTHON
			pyimpls+=( "${EPYTHON}" )
		fi
	done

	# Prepare and own the template
	insinto /etc/python-exec
	newins - python-exec.conf \
		< <(sed -n -e '/^#/p' config/python-exec.conf.example &&
			printf '%s\n' "${pyimpls[@]}" | tac)
}
