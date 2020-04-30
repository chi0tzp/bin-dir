#!/bin/bash
# TODO: add description

find . -type d | while read d; do

  dirname=`dirname "$d"`
  basename=`basename "$d"`
  echo $dirname, $basename
  if [ "$dirname" = "." ] && [ "$basename" != "." ]; then
    echo "Create pdfs in $basename"
  else
    # echo "convert all .jpg in $d/ and save to $dirname/$basename.pdf"
    convert "$d/*.jpg" "$dirname/$basename.pdf"
  fi
  # break

done
