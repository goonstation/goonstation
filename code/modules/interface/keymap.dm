
/datum/keymap
	var/list/keys = list()

	New(data)
		..()
		if (data)
			for (var/key in data)
				keys[parse_keybind(key)] = data[key]

	///Merges two keymaps together. Will overwrite existing entries sharing the same key.
	proc/merge(datum/keymap/init_keymap)
		for (var/key in init_keymap.keys)
			src.keys[key] = init_keymap.keys[key]

	///Overwrites existing entries from given keymap, matching on the action and not the key. Performance sucks on this.
	proc/overwrite_by_action(datum/keymap/writer)
		if (!writer) return
		for (var/key in writer.keys)
			var/new_key = key
			var/act = writer.keys[key]

			for (var/oldkey in src.keys)
				if (text2num(act)) //For number keys... needed ☹️
					if (src.keys[oldkey] == text2num(act))
						src.keys.Remove(oldkey)
						break
				else if (src.keys[oldkey] == act)
					src.keys.Remove(oldkey)
					break

			var/t2n = text2num(act)
			if (t2n)
				src.keys[new_key] = t2n
			else
				src.keys[new_key] = act

	proc/on_update(client/cl)
		var/list/winset_commands = list()
		for(var/action in global.action_macros)
			var/macro_id = global.action_macros[action]
			var/keybind = src.action_to_keybind(action)
			if(keybind)
				winset_commands += "base_macro.[macro_id].name=[keybind]"
		winset(cl, null, jointext(winset_commands, ";"))

	///Checks the input key and converts it to a usable format
	///Wants input in the format "CTRL+F", as an example.
	proc/parse_keybind(keybind)
		var/req_modifier = 0 //The modifier(s) associated with this key
		var/bound_key //The final key that should be bound
		var/list/keys = splittext(keybind, "+")
		if(keybind == "+")
			keys = list("+")

		if(keys.len > 1)
			//We have multiple keys (modifiers + normal ones)
			for(var/key in keys)
				//If it's a modifier key, then change the required modifier
				switch(key)
					if("ALT")
						req_modifier |= MODIFIER_ALT
					if("SHIFT")
						req_modifier |= MODIFIER_SHIFT
					if("CTRL")
						req_modifier |= MODIFIER_CTRL
					else
						//If it's not a modifier then use that as the target to bind
						bound_key = key
		else
			//Only one key. Force it to be a command
			bound_key = keybind

		ASSERT(bound_key) //If we didn't get a bound key something hecked the heck up.

		return uppertext("[req_modifier][bound_key]")

	///Converts the given usable format to a readable format
	///Wants input in the format "0NORTH" or "5D", as an example.
	proc/unparse_keybind(keytext)
		var/bound_key = ""
		var/modifier = text2num(copytext(keytext, 1, 2)) //The modifier(s) associated with this key (NUM/BITFLAG ONLY)
		var/modifier_string = ""

		if(modifier & MODIFIER_CTRL)
			modifier_string += "CTRL+"
		if(modifier & MODIFIER_ALT)
			modifier_string += "ALT+"
		if(modifier & MODIFIER_SHIFT)
			modifier_string += "SHIFT+"

		bound_key = copytext(keytext, 2)

		ASSERT(bound_key) //If we didn't get a bound key something hecked the heck up.

		return uppertext("[modifier_string][bound_key]")

	///Intermediate proc to check if an action is a bitflag or not before parsing it.
	proc/parse_action(action)
		if (isnum(action)) //for bitflag actions (KEY_BOLT)
			return key_bitflag_to_stringdesc(num2text(action))
		else //must be a string
			return key_string_to_desc(action)

	///Returns keybind for a given action
	proc/action_to_keybind(action)
		for(var/key_string in keys)
			var/action_string = keys[key_string]
			if(action_string == action)
				return unparse_keybind(key_string)
		return null

	///Converts from code-readable action names to human-readable
	///Example: "l_arm" to "Target Left Arm"
	proc/key_string_to_desc(string)
		for (var/key in action_names)
			if (string == key)
				return action_names[key]
		return "ZeWaka/Keybinds: not a string in action_names you fucko"

	///Converts from bitflag to a human-readable description
	///Example: "2" to "KEY_BACKWARD"
	proc/key_bitflag_to_stringdesc(bitflag)
		for (var/key in key_names)
			if (bitflag == key)
				return key_names[key]
		return "ZeWaka/Keybinds: not a bitflag in key_names you fucko"

	proc/check_keybind(pressed_key, modifier)
		//If there is a modifier command on this key, then use that
		var/command = keys[uppertext("[modifier][pressed_key]")]
		//Otherwise fall back on the default behaviour
		if(!command) command = keys[uppertext("0[pressed_key]")]
		//DEBUG_MESSAGE("Check keybind for [usr]. Key: [pressed_key], modifier: [modifier]. Found command: [command ? command : "-none-"]")
		return command
