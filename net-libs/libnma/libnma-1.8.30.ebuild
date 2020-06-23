# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="NetworkManager GUI library"
HOMEPAGE="https://wiki.gnome.org/Projects/NetworkManager"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~*"

IUSE="gtk +introspection"

RDEPEND="<gnome-extra/nm-applet-1.8.26[gtk?,introspection?]"
DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_unpack() { :; }
src_install() { :; }
