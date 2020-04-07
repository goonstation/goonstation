
/*
needed:
		smart key replacement - keep track of key and value from original and replace just that (deal with dupes) - not sure how to get orig keybind??
		movement key rebinding just don't work??? hardcoded?
		preference saving - use json_encode... shit into cloud somehow?
*/

chui/window/keybind_menu
	name = "Keybinding Customization"
	var/client/owner
	windowSize = "650x500"
	var/list/changed_keys //so we can keep track of what keys the user changes then merge later
	var/datum/keymap/current_keymap

	New(var/client/my_client)
		..()
		owner = my_client
		theAtom = owner.mob
		current_keymap = owner.keymap

	Subscribe(var/client/who)
		..()
		changed_keys = list() //new one every time so we're not merging an ever-expanding list (feel free to change if other is cheaper)

	GetBody()
		var/html = ""

		html += "<style>table, th, td{border: 2px solid #3c9eff; padding: 5px 5px 5px 5px; margin: 3px 3px 3px 3px; text-shadow: -1px -1px #000, -1px 1px #000, 1px -1px #000, 1px 1px #000}#confirm{background-color: #5bcca0; background: #5bcca0}#cancel{background-color: #ff445d; background: #ff445d}#reset{background-color: #f8d248; background: #f8d248}</style>"

		html += "<table style=\"text-align: center;\"><thead><tr><td colspan=\"2\"><b><i><span style=\"color: #ff445d;\">This is a keybind menu for a shitty game engine. It's your fault if you type it in wrong.</span></i></b></td></tr></thead><tbody>"

		html += "<tr><td>Action</td><td>Corresponding Keybind</td></tr>"

		boutput(world, "[json_encode(current_keymap.keys)]")

		for (var/key in current_keymap.keys)
			message_coders("beep beep: [key]")
			if (key == "0NORTH" || key == "0SOUTH" || key == "0EAST" || key == "0WEST") continue //ignore arrow keys, fuck you for making obscure-ass names lummox
			html += "<tr><td>[current_keymap.parse_action(current_keymap.keys[key])]</td><td><input class=\"input\" id=\"[current_keymap.keys[key]]\" type=\"text\" value=\"[current_keymap.unparse_keybind(key)]\"></td></tr>"

		html += "<tr><td>[theme.generateButton("confirm", "Confirm")]</td><td>[theme.generateButton("cancel", "Cancel")]</td></tr></tbody>"

		html += "<tfoot><tr><td colspan=\"2\">[theme.generateButton("reset", "Reset All Keybinds")]</td></tr></tfoot></table>"

		html += "<hr> <strong>Preset Templates:</strong> [theme.generateButton("set_arrow", "Arrow Keys")] [theme.generateButton("set_wasd", "WASD")] [theme.generateButton("set_tg", "/tg/")] [theme.generateButton("set_azerty", "AZERTY")] "
 
		html += "<script language=\"JavaScript\">$(\".input\").on(\"change keyup paste\", function(){var elem=$(this); chui.bycall(\"changed_key\", {action:elem.attr(\"id\"), key:elem.val()})})</script>"

		return html

	OnClick(var/client/who, var/id)
		if(owner)
			if (id == "confirm")
				if (changed_keys.len)
					boutput(world, "chang - [json_encode(changed_keys)]")

					var/changed_keys_rev = list()

					for (var/i in changed_keys)
						changed_keys_rev[changed_keys[i]] = i

					var/datum/keymap/keydat = new(changed_keys_rev) //this should only have the changed entries, for optimial merge
					owner.keymap.overwrite_by_action(keydat)

					owner.cloud_put("keybind_data", json_encode(owner.keymap.keys))
				
			else if (id == "set_wasd")
				changed_keys = new/list()
				//who.mob.
			else if (id == "set_tg")
				changed_keys = new/list()
			else if (id == "set_azerty")
				changed_keys = new/list()

			else if (id == "reset")
				boutput(world, "rasat")
				who.mob.reset_keymap()
				changed_keys = new/list()
			else if (id == "cancel")
				Unsubscribe(who)

	OnTopic(var/client/myclient, href, href_list[] )
		boutput(world, "bigtopic - [json_encode(href)]")
		var/action = href_list[ "_cact" ]
		if( action == "changed_key" && href_list["action"] && href_list["key"])
			add_to_changed(href_list["action"], uppertext(href_list["key"]) )
			var/acte = href_list["action"]
			var/keye = href_list["key"]
			boutput(world, "ADD CHANGE - [acte] - [keye]")

	proc/add_to_changed(var/action, var/key)
		key = uppertext(key) //keys are always uppertext
		changed_keys[action] = key
		boutput(world, "GONE ADDED - [action] - [key]")

/client/verb/modify_keybinds()
	set name = "Modify your Keybinds!"
	set desc = "Open up a handy window to change your keybinds"

	if(!keybind_menu)
		keybind_menu = new(src)
	keybind_menu.Subscribe(src)
