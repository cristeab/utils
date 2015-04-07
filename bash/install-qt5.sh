#!/bin/bash

#updates Qt5 sources and rebuilds several modules
CONFIG_OPTS="-developer-build -nomake examples -nomake tests -opensource -confirm-license -release"
#CONFIG_OPTS="-nomake examples -nomake tests -opensource -confirm-license -release"

#check platform type
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' || "$unamestr" == 'Darwin' ]]; then
  platform=$unamestr
else
  echo "Error: Unknown platform"
  exit 1
fi
if [[ "$platform" == 'Darwin' ]]; then
  echo "Building for iOS target"
  CONFIG_OPTS="$CONFIG_OPTS -xplatform macx-ios-clang"
  #check input arguments if any
  if [[ 0 -ne $# && "-e" -eq $1 ]]; then
    echo "Building for external device"
    CONFIG_OPTS="$CONFIG_OPTS -sdk iphoneos"
  else
    echo "Building for simulator"
    CONFIG_OPTS="$CONFIG_OPTS -sdk iphonesimulator"
  fi
fi

assert_rc()
{
  if [ 0 -ne "$?" ]; then
    echo "Error: $1"
    exit 1
  fi
}

update_branch()
{
  git co dev
  if [ 0 -ne "$?" ]; then
    git co -tb dev origin/dev
  fi
  assert_rc "Cannot update branch"
  git clean -dfx
  git pull
}

build_module()
{
  update_branch
  ../qtbase/bin/qmake
  make
  assert_rc "Cannot build module"
}

#install module in qtbase folder
install_module()
{
  cp -r include/ ../qtbase/
  cp -r lib/ ../qtbase/
  cp -r mkspecs/ ../qtbase/
}

#install headers in src root folder (should use instead -developer-build)
install_headers()
{
  cp -r qscript/src/script/ qtbase/src/
  cp -r qscript/src/scripttools/ qtbase/src/
  cp -r qtquick1/src/declarative/ qtbase/src/
  cp -r qtmultimedia/src/multimedia/ qtbase/src/
  cp -r qtxmlpatterns/src/xmlpatterns/ qtbase/src/
}

cd qtbase
assert_rc "This script should be started from the root folder"
echo "Build qtbase ..."
update_branch
./configure `echo -n "$CONFIG_OPTS"`
assert_rc "Cannot configure qtbase"
make
assert_rc "Cannot build qtbase"

echo "Build qtscript ..."
cd ../qtscript
#build_module

echo "Build qtquick1 ..."
cd ../qtquick1
#build_module

echo "Build qtmultimedia ..."
cd ../qtmultimedia
#build_module

echo "Build qtxmlpatterns ..."
cd ../qtxmlpatterns
#build_module
