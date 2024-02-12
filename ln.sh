#!/bin/sh

for file in .*; do
    if [ "$file" = ".git" ]
    then
        continue
    fi
    ln -s ${PWD}/${file} ${HOME}
done
