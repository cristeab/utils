#!/usr/bin/sh

git archive --format=tar.gz --prefix="$1"/ HEAD >"$1".tar.gz
