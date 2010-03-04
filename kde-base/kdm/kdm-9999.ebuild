# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

KMNAME="kdebase-workspace"
inherit kde4-meta flag-o-matic

DESCRIPTION="KDE login manager, similar to xdm and gdm"
KEYWORDS=""
IUSE="consolekit debug +handbook kerberos pam"

DEPEND="
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-libs/libXtst
	consolekit? (
		>=sys-apps/dbus-1.0.2
		sys-auth/consolekit
	)
	kerberos? ( virtual/krb5 )
	pam? (
		$(add_kdebase_dep kcheckpass)
		virtual/pam
	)
"
RDEPEND="${DEPEND}
	$(add_kdebase_dep kdepasswd)
	>=x11-apps/xinit-1.0.5-r2
	x11-apps/xmessage
"

KMEXTRACTONLY="
	kcontrol/kdm/
"
KMEXTRA="
	libs/kdm/
"

PATCHES=(
	"${FILESDIR}/kdebase-4.0.2-pam-optional.patch"
	"${FILESDIR}/${PN}-4-gentoo-xinitrc.d.patch"
)

pkg_setup() {
	kde4-meta_pkg_setup

	# Create kdm:kdm user
	KDM_HOME=/var/lib/kdm
	enewgroup kdm
	enewuser kdm -1 -1 "${KDM_HOME}" kdm
}

src_configure() {
	# genkdmconf breaks with -O3
	# last checked in 4.2.95
	replace-flags -O3 -O2

	mycmakeargs=(
		$(cmake-utils_use kerberos KDE4_KRB5AUTH)
		$(cmake-utils_use_with pam)
		$(cmake-utils_use_with consolekit CkConnector)
	)

	kde4-meta_src_configure
}

src_install() {
	export GENKDMCONF_FLAGS="--no-old --no-backup"

	kde4-meta_src_install

	# Upstream no longer calls this... (remove when upstream decides what
	# its going to do about it)
	${CMAKE_BUILD_DIR}/kdm/kfrontend/genkdmconf \
		--in "${ED}${KDEDIR}/share/config/kdm" \
		--no-in-notice \
		--face-src "${S}/kdm/kfrontend/pics" \
		${GENKDMCONF_FLAGS} \
		|| die "genkdmconf failed"

	# Customize the kdmrc configuration
	sed -i -e "s:^.*SessionsDirs=.*$:#&\nSessionsDirs=${EPREFIX}/usr/share/xsessions:" \
		"${ED}"/${KDEDIR}/share/config/kdm/kdmrc \
		|| die "Failed to set SessionsDirs correctly."

	# Don't install empty dir
	rmdir "${ED}${KDEDIR}"/share/config/kdm/sessions

	# Set up permissions to kdm work directory
	keepdir "${KDM_HOME}"
	fowners root:kdm "${KDM_HOME}"
	fperms 1770 "${KDM_HOME}"
}

pkg_postinst() {
	kde4-meta_pkg_postinst

	# Set the default kdm face icon if it's not already set by the system admin
	# because this is user-overrideable in that way, it's not in src_install
	if [[ ! -e "${EROOT}${KDEDIR}/share/apps/kdm/faces/.default.face.icon" ]]; then
		mkdir -p "${EROOT}${KDEDIR}/share/apps/kdm/faces"
		cp "${EROOT}${KDEDIR}/share/apps/kdm/pics/users/default1.png" \
			"${EROOT}${KDEDIR}/share/apps/kdm/faces/.default.face.icon"
	fi
	if [[ ! -e "${EROOT}${KDEDIR}/share/apps/kdm/faces/root.face.icon" ]]; then
		mkdir -p "${EROOT}${KDEDIR}/share/apps/kdm/faces"
		cp "${EROOT}${KDEDIR}/share/apps/kdm/pics/users/root1.png" \
			"${EROOT}${KDEDIR}/share/apps/kdm/faces/root.face.icon"
	fi

	if use consolekit; then
		echo
		elog "You have compiled 'kdm' with consolekit support. If you want to use kdm,"
		elog "make sure consolekit daemon is running and started at login time"
		elog
		elog "rc-update add consolekit default && /etc/init.d/consolekit start"
		echo
	fi
}
