#!/bin/sh

for file in .*; do
  if [ "$file" = "." ] || [ "$file" = ".." ] || [ "$file" = ".git" ]; then
    continue
  fi

  if [ -d "$file" ]; then
    echo "Skipping directory: ${file}"
    continue
  fi

  echo "Linking file: ${file}"
  ln -sf "${PWD}/${file}" "${HOME}/${file}"
done
