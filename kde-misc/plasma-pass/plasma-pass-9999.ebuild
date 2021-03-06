# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit kde5

DESCRIPTION="Plasma applet to access password from pass"
HOMEPAGE="https://cgit.kde.org/scratch/dvratil/plasma-pass.git"
EGIT_REPO_URI="https://anongit.kde.org/scratch/dvratil/plasma-pass.git"
LICENSE="LGPL-2.1+"
IUSE=""

DEPEND="
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep kitemmodels)
	$(add_frameworks_dep plasma)
	$(add_qt_dep qtdbus)
	$(add_qt_dep qtdeclarative)
	$(add_qt_dep qtgraphicaleffects)
	$(add_qt_dep qtgui)
"
RDEPEND="${DEPEND}
	app-admin/pass
"
