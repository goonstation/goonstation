#!/bin/bash
# By /tg/station and Yogstation
# Please mirror to check_grep.sh
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar

st=0

# Map Checks

if grep -El '^\".+\" = \(.+\)' +secret/**/*.dmm assets/maps/**/*.dmm maps/**/*.dmm;	then
   echo "ERROR: Non-TGM formatted map detected. Please convert it using Map Merger or StrongDMM!"
   st=1
fi;

if grep -P '/obj/landmark/spawner{' +secret/**/*.dmm assets/maps/**/*.dmm maps/**/*.dmm;	then
    echo "ERROR: instanced /obj/landmark/spawner detected on a map, please create a subtype."
    st=1
fi;

if grep -P 'step_[xy]' +secret/**/*.dmm assets/maps/**/*.dmm maps/**/*.dmm;	then
    echo "ERROR: step_x/step_y variables detected in maps, please remove them."
    st=1
fi;

# We check for this as well to ensure people aren't actually using this mapping effect in their maps.
if grep -P '/obj/merge_conflict_marker' +secret/**/*.dmm assets/maps/**/*.dmm maps/**/*.dmm; then
    echo "ERROR: Merge conflict markers detected in map, please resolve all merge failures!"
    st=1
fi;

# Code Checks

if grep -P 'playsound\(([^,]*), "(sound\/[^\[]+)"' code/**/*.dm;	then
    echo "ERROR: improper playsound call detected, please fix according to code guide."
    st=1
fi;

if grep -P 'plane\s*=\s*[0-9]+|plane\s*=\s*[A-Z_]+\s*[+\-*]\s*' */**/*.dm;	then
    echo "ERROR: don't directly set plane to a number, please use a define."
    st=1
fi;

if grep -P 'rand\([^)]*[0-9]\.' */**/*.dm;	then
    echo "ERROR: rand() does not support floating point numbers, use randfloat() instead."
    st=1
fi;


if grep -P '^ABSTRACT_TYPE\([^/]' */**/*.dm;	then
    echo "ERROR: You need to include the slash before the area type name in ABSTRACT_TYPE."
    st=1
fi;

if grep -P "(?<!UNLINT\().*name = .*\"\[.*\]'s" */**/*.dm;   then
	echo "ERROR: Using an apostrophe in a name like [mob]'s brain may cause Byond to get confused between the two objects in click verbs etc. Please use ’ (U+2019) instead."
	st=1
fi;

exit $st
