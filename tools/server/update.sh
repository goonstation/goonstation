#!/bin/bash
shopt -s dotglob

cd /ss13_server

detect_hard_reboot () {
	CURRENT_BUILD_ENV=$(cat .env.build 2> /dev/null)
	UPDATE_BUILD_ENV=$(cat update/.env.build 2> /dev/null)

	CURRENT_BYOND_MAJOR=$(echo "$CURRENT_BUILD_ENV" | awk -F= '/^BYOND_MAJOR_VERSION/ { print $2 }')
	CURRENT_BYOND_MINOR=$(echo "$CURRENT_BUILD_ENV" | awk -F= '/^BYOND_MINOR_VERSION/ { print $2 }')
	CURRENT_BYOND="$CURRENT_BYOND_MAJOR.$CURRENT_BYOND_MINOR"

	UPDATE_BYOND_MAJOR=$(echo "$UPDATE_BUILD_ENV" | awk -F= '/^BYOND_MAJOR_VERSION/ { print $2 }')
	UPDATE_BYOND_MINOR=$(echo "$UPDATE_BUILD_ENV" | awk -F= '/^BYOND_MINOR_VERSION/ { print $2 }')
	UPDATE_BYOND="$UPDATE_BYOND_MAJOR.$UPDATE_BYOND_MINOR"

	CURRENT_RUSTG=$(echo "$CURRENT_BUILD_ENV" | awk -F= '/^RUSTG_VERSION/ { print $2 }')
	UPDATE_RUSTG=$(echo "$UPDATE_BUILD_ENV" | awk -F= '/^RUSTG_VERSION/ { print $2 }')

	if [ "$CURRENT_BYOND" != "$UPDATE_BYOND" ] || [ "$CURRENT_RUSTG" != "$UPDATE_RUSTG" ]; then
		echo "New dependencies detected, triggering a hard reboot"
		touch data/hard-reboot
	fi
}

if [ -n "$(ls -A update)" ]; then
	echo "New updates detected"
	if [ "$1" == "--from-game" ]; then
		detect_hard_reboot
	fi

	echo "Applying updates"
	cd update
	# Replace directories with update directories
	ls -1d */ 2> /dev/null | rsync -a --remove-source-files --delete-before --files-from=- . ..
	find . -depth -type d -empty -delete
	# Move any remaining top-level files up
	mv * ..
	cd ..
	rm *.dyn.rsc 2> /dev/null
	echo "Update complete"
fi
