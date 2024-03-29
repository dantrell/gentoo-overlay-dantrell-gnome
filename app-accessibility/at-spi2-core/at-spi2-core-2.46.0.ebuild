# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit multilib-build

DESCRIPTION="Virtual for D-Bus accessibility specifications and registration daemon"
HOMEPAGE="https://wiki.gnome.org/Accessibility https://gitlab.gnome.org/GNOME/at-spi2-core"

LICENSE="metapackage"
SLOT="2"
KEYWORDS="*"

IUSE="X gtk-doc +introspection"

RDEPEND="|| (
	>=app-accessibility/at-spi2-core-base-2.46.0:2[${MULTILIB_USEDEP}]
	(
		>=dev-libs/atk-2.14.0[${MULTILIB_USEDEP}]
		>=app-accessibility/at-spi2-core-base-2.14.0[X?,gtk-doc(+)?,introspection?,${MULTILIB_USEDEP}]
	)
)"
