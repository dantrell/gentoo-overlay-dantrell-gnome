# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="A sub-package that provides common GNOME Shell files"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeShell"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	dev-libs/glib:2=
	|| (
		gnome-extra/gnome-shell-extensions
		gnome-base/gnome-shell
	)
"
DEPEND="${RDEPEND}"

S="${FILESDIR}"

src_install() {
	insinto /usr/share/gnome-shell/theme/

	if has_version "<gnome-base/gnome-shell-3.16.0"; then
		newins "${S}"/calendar-today-blob.svg calendar-today.svg
	elif has_version "<gnome-base/gnome-shell-3.18.0" || has_version "gnome-base/gnome-shell[deprecated-background]"; then
		newins "${S}"/calendar-today-dot.svg calendar-today.svg
	else
		newins "${S}"/calendar-today-dot-dark.svg calendar-today.svg
	fi
}
