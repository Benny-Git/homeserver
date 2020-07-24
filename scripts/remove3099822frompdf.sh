#!/bin/bash

for var in "$@"
do
  echo -n "fixing $var ... "
  pdftk "$var" output - uncompress | sed -e "s/3099822/ /" | pdftk - output "$var" compress
  echo "done fixing $var ."
done
