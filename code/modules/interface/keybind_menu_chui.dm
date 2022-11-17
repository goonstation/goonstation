
chui/window/keybind_menu
	name = "Keybinding Customization"
	var/client/owner
	windowSize = "700x550"
	var/list/changed_keys //so we can keep track of what keys the user changes then merge later
	var/datum/keymap/current_keymap
	var/last_interact_time //To rate-limit
	var/const/rate_limit_time = 1 SECOND

	New(client/my_client)
		..()
		owner = my_client
		theAtom = owner.mob
		current_keymap = owner.keymap

	Subscribe(client/who)
		..()
		changed_keys = list() //new one every time so we're not merging an ever-expanding list (feel free to change if cheaper)

	GetBody()

		current_keymap = owner.keymap //Need to refresh this since it's not a proper pointer?

		var/list/html = list()

		html += "<style>table, th, td{border: 2px solid #3c9eff; padding: 5px 5px 5px 5px; margin: 3px 3px 3px 3px; text-shadow: -1px -1px #000, -1px 1px #000, 1px -1px #000, 1px 1px #000}#confirm{background-color: #5bcca0; background: #5bcca0}#cancel{background-color: #ff445d; background: #ff445d}#reset,#reset_cloud{background: #f8d248}</style>"

		html += "<table style=\"text-align: center;\"><thead><tr><td colspan=\"2\"><b><i><span style=\"color: #ff445d;\">You can only rebind keys you have access to when opening the window. Ex: You can only change human hotkeys if you are currently human.</span></i></b></td></tr></thead>"

		html += "<tbody><tr><td>Action</td><td>Corresponding Keybind</td></tr>"

		for (var/key in current_keymap.keys)
			if (key == "0NORTH" || key == "0SOUTH" || key == "0EAST" || key == "0WEST") continue //ignore arrow keys, fuck you for making obscure-ass names lummox
			html += "<tr><td>[current_keymap.parse_action(current_keymap.keys[key])]</td><td><input class=\"input\" id=\"[current_keymap.keys[key]]\" type=\"text\" value=\"[current_keymap.unparse_keybind(key)]\"></td></tr>"

		html += "<tr><td>[theme.generateButton("confirm", "Confirm")]</td><td>[theme.generateButton("cancel", "Cancel")]</td></tr></tbody>"

		html += "<tfoot><tr><td colspan=\"2\">[theme.generateButton("reset", "Reset All Keybinding Data (Caution!)")]</td></tr></tfoot></table>"

		html += "<script language=\"JavaScript\">$(\".input\").on(\"change keyup paste\", function(){var elem=$(this); chui.bycall(\"changed_key\", {action:elem.attr(\"id\"), key:elem.val()})})</script>"

		return html.Join()

	OnClick(client/who, id)
		if (TIME < last_interact_time + rate_limit_time) return
		if(owner)
			if (id == "confirm")
				if (changed_keys.len)
					var/changed_keys_rev = list()

					for (var/i in changed_keys)
						changed_keys_rev[changed_keys[i]] = i

					var/datum/keymap/keydat = new(changed_keys_rev) //this should only have the changed entries, for optimal merge
					current_keymap.overwrite_by_action(keydat)
					current_keymap.on_update(owner)
					owner.cloud_put("custom_keybind_data", json_encode(changed_keys_rev))
					boutput("<span class='notice'>Your custom keybinding data has been saved.</span>")
			else if (id == "reset")
				changed_keys = new/list()
				owner.cloud_put("custom_keybind_data", null)
				who.keymap = null //To prevent merge() from not overwriting old keybinds
				who.mob.reset_keymap() //Does successive calls to rebuild the keymap
				boutput(who, "<span class='notice'>Your keybinding data has been reset. Please re-open the window.</span>")
				Unsubscribe(who)
			else if (id == "cancel")
				Unsubscribe(who)
			last_interact_time = TIME

	//This shitfuckery is because chui doesn't have proper JS interface junk.
	OnTopic(client/myclient, href, href_list[] )
		var/action = href_list[ "_cact" ]
		if( action == "changed_key" && href_list["action"] && href_list["key"])
			add_to_changed(href_list["action"], uppertext(href_list["key"]) )

	proc/add_to_changed(action, key)
		changed_keys[action] = uppertext(key) //keys are always uppertext

/client/verb/modify_keybinds()
	set hidden = 1
	set name = "modify-keybinds"

	if(!src.keybind_menu)
		src.keybind_menu = new(src)
	src.keybind_menu.Subscribe(src)
