#/bin/bash
#
# OPEW Bash Installer - Bash-based installer builder utility for the OPEW project
# This was developed for the OPEW project <http://opew.sf.net>
#
# @license	GNU GPL 3.0
# @author	Tomas Aparicio <tomas@rijndael-project.com>
# @version	2.2 beta - revision 17/04/2012
# 
# Copyright (C) 2012 - Tomas Aparicio
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#

# static variables
TMPDIR=tmp/ # temporal output directory
PKGDIR=pkg/ # packages output directory
VERSION="2.2 Beta" # version 
LOGOUT=build.out.log
ERROR=0

#
# base functions
#

# 
# Check if exists a binary/file looking on the $PATH folders 
# @param {String} Binary/file to check 
#
function _check 
{
    type "$1" &> /dev/null ;
}

# check PATH environment variable
if [ -z $PATH ]; then
	echo "The PATH environment variable is empty."
	echo "Must be defined in order to run this script properly. "
	echo "Please, copy and ejecute this (or your customized PATH environment): " 
	echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
	exit 1
fi

# required run like root user
if [ "`id -u`" -ne 0 ];	then
       	echo "ERROR: "
	echo "You must run like a root user. You can't continue..."
       	exit 1
fi

# check OS binary tools required by the installer builder
for i in $(echo "source;dirname;type;read;awk;head;tail;wc;tar;df" | tr ";" "\n")
do
	if ! _check $i ; then
		echo " "
		echo "Error:"
		echo "The binary tool '$i' not found in the system (looking using PATH env variable)"
		echo "Check it or install '$i' via your package manager and try again with the installation"
		echo " "
		ERROR=1
	fi
done
if [ $ERROR -eq 1 ]; then
	echo "Cannot continue. Exiting."
	exit 1
fi

# check required scripts
if [ ! -x "$(dirname $0)/lib/base.bash" ]; then
	echo "Error: not found $(dirname $0)/lib/custom.inc or not cannot have exec permissions. Required. Exiting."
	exit 1
fi

# output header info
cat <<- _EOF_
--------------------------------------------------------
 OPEW Bash Installer ($VERSION)
 A simple UNIX bash-based installer builder utility

 Author: Tomas Aparicio <tomas@rijndael-project.com>
 License: GNU GPL 3.0
 Code: <http://github.com/h2non/OPEW-bash-installer>
 Note: this utility was developed for the OPEW project.
 More info: <http://opew.sf.net> 
--------------------------------------------------------

Please, follow the wizard

_EOF_

# define the OPEW release version
read -p "OPEW build version: " res
if [ -z $res ]; then
    echo "You must enter an OPEW version. Cannot continue. "
    exit 1
else 
    VERSION=$res
fi

# define the OPEW architecture
read -p "OPEW processor architecture (x64|x86): " res
if [ -z $res ]; then
    _ARCH="x64"
else 
    _ARCH=$res
fi

# output file
_OUTPUT="opew-$VERSION-$_ARCH.bin"

read -p "Select one: " res
case $res in
	1)
	 source $(dirname $0)/inc/simple.inc
	;;
	4)
	 echo "Exiting."
	 exit 0
	;;
	*) 
	 echo "Invalid option. Exiting."
	 exit 1
	;;
esac
