#!/bin/bash

assert_rc()
{
  if [ 0 -ne "$?" ]; then
    echo "Error: $1"
    exit 1
  fi
}

cp -r include/ ../qtbase/
assert_rc "Should be called from the module root folder"
cp -r lib/ ../qtbase/
cp -r mkspecs/ ../qtbase/
