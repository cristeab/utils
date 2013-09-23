#!/bin/bash

#*****************************************************************#
#                       install_itpp.bash                         #
#                    written by Bogdan Cristea                    #
#                      August 25, 2009                         #
#                                                                 #
#                      Installs IT++ library                      #
#*****************************************************************#

HELP_OPT=-h #display help message
AUTOGEN_OPT=-a #run autogen.sh
SP_OPT=-s #single processor architecture
DBG_OPT=-d #generate debug version
WAIT_OPT=-w #wait a given number of seconds after configure
WAIT_SEC=10
PATH_TO_ACML=/opt/acml5.1.0

#display help and exit
if [ "$1" == "$HELP_OPT" ]; then
	echo "Usage: `basename $0` -h -a -s -d -w"
	echo "-h display this help message"
	echo "-a run autogen.sh (default don't run)"
	echo "-s single processor architecture (default multi processor)"
	echo "-d generate debug version"
	echo "-w wait $WAIT_SEC seconds after configure"
	echo "Please note that the order of parameters is important, but some parameters can be omitted"
	exit 0
fi

read -p "Path to IT++ sources ? " ITPP_SRC_PATH

cd "$ITPP_SRC_PATH"

#default don't run autogen.sh
if [ "$1" == "$AUTOGEN_OPT" ]; then
	./autogen.sh
	shift
fi

make clean
make distclean

if [ "$1" == "$SP_OPT" ]; then #link against single processor libraries
	#make sure to use the right compiler
	export CC="gcc"
	export CXX="g++"
	export F77="gfortran"
	export LDFLAGS="-L"$PATH_TO_ACML"/gfortran64/lib"
	export CPPFLAGS="-I"$PATH_TO_ACML"/gfortran64/include"
	CONF_OPT=acml
	export CXXFLAGS="-DNDEBUG -Wall -O3 -pipe -march=athlon64"
	shift
else #default link against multiple processor libraries
	#make sure to use the right compiler
	export CC="gcc"
	export CXX="g++"
	export F77="gfortran"
	export LDFLAGS="-L"$PATH_TO_ACML"/gfortran64_mp/lib"
	export CPPFLAGS="-I"$PATH_TO_ACML"/gfortran64_mp/include"
	CONF_OPT=acml_mp
	export CXXFLAGS="-DNDEBUG -Wall -O3 -pipe -march=athlon64 -fopenmp"
fi

if [ "$1" == "$DBG_OPT" ]; then #debug version
	export CXXFLAGS_DEBUG="-ggdb -O0 -pipe -march=athlon64"
	./configure --enable-static --enable-debug --with-blas="$CONF_OPT"
	shift
else #default non debug version
	./configure --enable-static --with-blas="$CONF_OPT"
fi

if [ "$1" == "$WAIT_OPT" ]; then
	echo -e "\nPress any key within" $WAIT_SEC "sec. to exit"
	read -s -n1 -t"$WAIT_SEC" #no echo, read a single char, wait WAIT_SEC seconds
	if [ "$?" -eq 0 ]; then #if a key is pressed exit
	    echo #new line before exiting
	    exit 0
	fi
fi

make

make check

sudo make install
