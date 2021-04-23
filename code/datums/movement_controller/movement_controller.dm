/datum/movement_controller
	proc
		keys_changed(mob/owner, keys, changed)
			// stub

		process_move(mob/owner, keys)
			// stub

		hotkey(mob/user, name)

		modify_keymap(client/C)
			SHOULD_CALL_PARENT(TRUE)
			// stub

		update_owner_dir()
