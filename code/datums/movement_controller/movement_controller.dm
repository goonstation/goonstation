/datum/movement_controller
	proc
		keys_changed(mob/owner, keys, changed)
			// stub

		process_move(mob/owner, keys)
			// stub

		hotkey(mob/user, name)

		modify_keymap(datum/keymap/keymap, client/C)
			// stub

		update_owner_dir(var/atom/movable/owner)


	disposing()
		..()
