# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Graphical front-ends to various networking command-line"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-nettool"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="debug"

COMMON_DEPEND="
	>=dev-libs/glib-2.25.10:2
	gnome-base/libgtop:2=
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-2.90.4:3
	x11-libs/pango
"
RDEPEND="${COMMON_DEPEND}
	|| (
		net-misc/iputils
		net-analyzer/tcptraceroute
		net-analyzer/traceroute )
	net-analyzer/nmap
	net-dns/bind-tools
	net-misc/netkit-fingerd
	net-misc/whois
"
DEPEND="${COMMON_DEPEND}
	app-text/yelp-tools
	>=dev-util/intltool-0.40
	virtual/pkgconfig
	sys-devel/gettext
"

src_configure() {
	gnome2_src_configure $(use_enable debug)
}
