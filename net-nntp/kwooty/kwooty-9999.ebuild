# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_BRANCH="frameworks"
inherit kde5

DESCRIPTION="Friendly nzb linux usenet binary client"
HOMEPAGE="https://www.linux-apps.com/content/show.php/Kwooty?content=114385"

LICENSE="GPL-2+"
KEYWORDS=""
IUSE=""

DEPEND="
	$(add_frameworks_dep kcmutils)
	$(add_frameworks_dep kconfig)
	$(add_frameworks_dep kconfigwidgets)
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep kdelibs4support)
	$(add_frameworks_dep kguiaddons)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep kiconthemes)
	$(add_frameworks_dep kio)
	$(add_frameworks_dep knotifications)
	$(add_frameworks_dep kservice)
	$(add_frameworks_dep kwallet)
	$(add_frameworks_dep kwidgetsaddons)
	$(add_frameworks_dep kwindowsystem)
	$(add_frameworks_dep kxmlgui)
	$(add_qt_dep qtdbus)
	$(add_qt_dep qtgui)
	$(add_qt_dep qtnetwork)
	$(add_qt_dep qtwidgets)
"
RDEPEND="${DEPEND}
	!net-nntp/kwooty:4
"

src_prepare() {
	kde5_src_prepare

	sed -i -e "/KF5DocTools/d" CMakeLists.txt || die
}

pkg_postinst() {
	kde5_pkg_postinst

	if ! has_version "app-arch/par2cmdline" ; then
		elog "For automatic file repairing please install app-arch/par2cmdline."
	fi

	if ! has_version "app-arch/unrar" ; then
		elog "For automatic RAR archive extraction please install app-arch/unrar."
	fi

	if ! has_version "app-arch/p7zip" ; then
		elog "For automatic (7)zip archive extraction please install app-arch/p7zip."
	fi
}
