#!/bin/bash

#Project dependencies file
#Final authority on what's required to fully build the project

# byond version
# Extracted from the Dockerfile. Change by editing Dockerfile's FROM command.
# TODO: sed this from buildByond.conf
export BYOND_MAJOR=513
export BYOND_MINOR=1508

# SpacemanDMM git tag
export SPACEMAN_DMM_VERSION=suite-1.3
