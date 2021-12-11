#!/bin/bash
# By /tg/station and Yogstation
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar

st=0

#if grep -El '^\".+\" = \(.+\)' maps/**/*.dmm;	then
#    echo "ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!"
#    st=1
#fi;
if grep -P 'step_[xy]' maps/**/*.dmm;	then
    echo "ERROR: step_x/step_y variables detected in maps, please remove them."
    st=1
fi;

if grep -P '^\s*New\s*\(|(?<!client|world)\/New\(' code/**/*.dm;	then
    echo "ERROR: New() override detected, please replace with INIT or INIT_TYPE."
    st=1
fi;

exit $st
