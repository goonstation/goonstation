#!/bin/bash
# By /tg/station and Yogstation
# Please mirror to check_grep_secret.sh
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar

st=0

# Map Checks

if grep -El '^\".+\" = \(.+\)' assets/maps/**/*.dmm maps/**/*.dmm;	then
   echo "ERROR: Non-TGM formatted map detected. Please convert it using Map Merger or StrongDMM!"
   st=1
fi;

if grep -P '/obj/landmark/spawner{' assets/maps/**/*.dmm maps/**/*.dmm;	then
    echo "ERROR: instanced /obj/landmark/spawner detected on a map, please create a subtype."
    st=1
fi;

if grep -P 'step_[xy]' assets/maps/**/*.dmm maps/**/*.dmm;	then
    echo "ERROR: step_x/step_y variables detected in maps, please remove them."
    st=1
fi;

if grep -P '^\/area(?!\/dmm_suite\/clear_area)' assets/maps/random_rooms/**/*.dmm; then
    echo "ERROR: random room uses non '/area/dmm_suite/clear' area"
    st=1
fi;

# We check for this as well to ensure people aren't actually using this mapping effect in their maps.
if grep -P '/obj/merge_conflict_marker' assets/maps/**/*.dmm maps/**/*.dmm; then
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

if grep -P 'istype\([^,)]*\.type' */**/*.dm;	then
    echo "ERROR: you probably meant to use istype(foo, sometype) instead of istype(foo.type, sometype)."
    st=1
fi;

if grep -P '^ABSTRACT_TYPE\([^/]' */**/*.dm;	then
    echo "ERROR: You need to include the slash before the area type name in ABSTRACT_TYPE."
    st=1
fi;

if grep -P '^ABSTRACT_TYPE\([^/]' */**/*.dm;	then
    echo "ERROR: You need to include the slash before the area type name in ABSTRACT_TYPE."
    st=1
fi;

if grep -P 'as anything in o?(range|hearers)' */**/*.dm;	then
    echo "ERROR: Don't include 'as anything' before o?range|hearers, it disables optimizations."
    st=1
fi;

exit $st
