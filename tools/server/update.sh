#!/bin/bash
shopt -s dotglob

cd /ss13_server

if [ -n "$(ls -A update)" ]; then
	echo "Applying updates"
	cd update
	# Replace directories with update directories
	ls -1d */ 2> /dev/null | rsync -ar --remove-source-files --delete-before --files-from=- . ..
	find . -depth -type d -empty -delete
	# Move any remaining top-level files up
	mv * .. 2> /dev/null
	cd ..
	rm *.dyn.rsc 2> /dev/null
	echo "Update complete"
fi
