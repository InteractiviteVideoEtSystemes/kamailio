#!/bin/bash

PROJET=kamailio

function svn_export
{
        svn export http://svn.ives.fr/svn-libs-dev/asterisk/${PROJET}
}


#Creation de l'environnement de packaging rpm
function create_rpm
{
    #Cree l'environnement de creation de package
    #Creation des macros rpmbuild
    rm ~/.rpmmacros
    touch ~/.rpmmacros
    echo "%_topdir" $PWD"/rpmbuild" >> ~/.rpmmacros
    echo "%_tmppath %{_topdir}/TMP" >> ~/.rpmmacros
    echo "%_signature gpg" >> ~/.rpmmacros
    echo "%_gpg_name IVeSkey" >> ~/.rpmmacros
    echo "%_gpg_path" $PWD"/gnupg" >> ~/.rpmmacros
    echo "%vendor IVeS" >> ~/.rpmmacros
    #Import de la clef gpg IVeS
    svn export https://svn.ives.fr/svn-libs-dev/gnupg
    mkdir -p rpmbuild
    mkdir -p rpmbuild/SOURCES
    mkdir -p rpmbuild/SPECS
    mkdir -p rpmbuild/BUILD
    mkdir -p rpmbuild/SRPMS
    mkdir -p rpmbuild/TMP
    mkdir -p rpmbuild/RPMS
    mkdir -p rpmbuild/RPMS/noarch
    mkdir -p rpmbuild/RPMS/i386
    mkdir -p rpmbuild/RPMS/i686
    mkdir -p rpmbuild/RPMS/i586
    mkdir -p rpmbuild/RPMS/x86_64
    #Recuperation de la description du package 
    cd ./rpmbuild/SPECS/
    cp ../../pkg/kamailio/rpm/kamailio.spec.CenOS ${PROJET}.spec
    cd ../SOURCES
    ln -s ../.. ${PROJET}
    cp ../../pkg/kamailio/rpm/kamailio.init .
    cp ../../pkg/kamailio/rpm/kamailio.default .
    cd ../../
    #Cree le package
    if [[ -z $1 || $1 -ne nosign ]]
    then
             rpmbuild -bb --sign $PWD/rpmbuild/SPECS/${PROJET}.spec
    else
             rpmbuild -bb $PWD/rpmbuild/SPECS/${PROJET}.spec
    fi

    if [ $? == 0 ]
    then
        echo "************************* fin du rpmbuild ****************************"
        #Recuperation du rpm
        mv -f $PWD/rpmbuild/RPMS/x86_64/*.rpm $PWD/.
    fi
    clean
}

function clean
{
        # On efface les liens ainsi que le package precedemment crÃÃs
        echo Effacement des fichiers et liens
        rm -f rpmbuild/SOURCES/${PROJET} rpmbuild/SOURCES/kamailio.init rpmbuild/SOURCES/kamailio.default
        rm -f rpmbuild/SPECS/${PROJET}.spec
	rm -rf rpmbuild gnupg
}

case $1 in
  	"clean")
  		echo "Nettoyage des liens et du package crees par la cible dev"
  		clean ;;
  	"rpm")
  		echo "Creation du rpm"
  		create_rpm $2;;

	"prereq")
		sudo yum -y install postgresql-devel unixODBC-devel libpurple-devel mod_perl-devel lua-devel geoip-devel make flex bison pcre-devel mariadb-devel zlib-devel libxml2-devel radiusclient-ng-devel lm_sensors-devel net-snmp-devel libxml2-devel, curl-devel expat-devel openssl-devel libconfuse-devel openldap-devel libunistring-devel
		sudo yum -y install json-c-devel libevent-devel python ;;
  	*)
  		echo "usage: install.ksh [options]" 
  		echo "options :"
  		echo "  rpm		Generation d'un package rpm"
  		echo "  prepreq		Install des prerequis"
  		echo "  clean		Nettoie tous les fichiers ";;
esac
