
/datum/keybind_menu
	var/client/owner
	var/list/changed_keys //so we can keep track of what keys the user changes then merge later
	var/hasChanges = FALSE

	New(client/my_client)
		..()
		owner = my_client

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Keybinds")
			ui.open()

	ui_data(mob/user)
		. = ..()
		var/datum/keymap/current_keymap = owner.keymap
		var/list/keys = list()

		for (var/key in current_keymap.keys)
			if (key == "0NORTH" || key == "0SOUTH" || key == "0EAST" || key == "0WEST") continue //ignore arrow keys, fuck you for making obscure-ass names lummox

			keys.Add(list(list(
				label = current_keymap.parse_action(current_keymap.keys[key]),
				id = "[current_keymap.keys[key]]",
				savedValue = current_keymap.unparse_keybind(key),
				changedValue = changed_keys["[current_keymap.keys[key]]"]
			)))

		.["keys"] = keys
		.["hasChanges"] = hasChanges

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()

		var/datum/keymap/current_keymap = owner.keymap

		switch (action)
			if ("changed_key")
				if (params["id"] && params["value"])
					add_to_changed(params["id"], uppertext(params["value"]) )
					hasChanges = TRUE
					. = TRUE

			if ("confirm")
				if (changed_keys.len)
					var/changed_keys_rev = list()

					for (var/i in changed_keys)
						changed_keys_rev[changed_keys[i]] = i

					var/datum/keymap/keydat = new(changed_keys_rev) //this should only have the changed entries, for optimal merge
					current_keymap.overwrite_by_action(keydat)
					current_keymap.on_update(owner)
					var/fetched_keylist = owner.player?.cloudSaves.getData("custom_keybind_data")
					var/new_keybind_data = list()
					if (!isnull(fetched_keylist) && fetched_keylist != "") //The client has a list of custom keybinds.
						new_keybind_data = json_decode(fetched_keylist)
					for (var/i in changed_keys_rev)
						new_keybind_data[i] = changed_keys_rev[i]
					owner.player?.cloudSaves.putData("custom_keybind_data", json_encode(new_keybind_data))
					boutput(owner, SPAN_NOTICE("Your custom keybinding data has been saved."))
					hasChanges = FALSE
					. = TRUE
			if ("reset")
				changed_keys = new/list()
				owner.player?.cloudSaves.deleteData("custom_keybind_data")
				owner.keymap = null //To prevent merge() from not overwriting old keybinds
				owner.mob.reset_keymap() //Does successive calls to rebuild the keymap
				boutput(owner, SPAN_NOTICE("Your keybinding data has been reset."))
				tgui_process.close_uis(src)
			if ("cancel")
				tgui_process.close_uis(src)

	proc/add_to_changed(id, value)
		changed_keys[id] = uppertext(value) //keys are always uppertext


	ui_status(mob/user, datum/ui_state/state)
		return tgui_always_state.can_use_topic(src, user)

/client/verb/modify_keybinds()
	set hidden = 1
	set name = "modify-keybinds"

	if(!src.keybind_menu)
		src.keybind_menu = new(src)
	src.keybind_menu.changed_keys = list()
	src.keybind_menu.hasChanges = FALSE
	src.keybind_menu.ui_interact(src.mob)
