datum/pump_ui
	var/pump_name
	var/value_name
	var/value_units
 	// Min and max values for the pump control to have
	var/min_value
	var/max_value
 	// Increments for the + and - buttons
	var/incr_sm
	var/incr_lg

 // These need to be overridden in the children
datum/pump_ui/proc/set_value(value_to_set)
datum/pump_ui/proc/toggle_power()
datum/pump_ui/proc/is_on()
datum/pump_ui/proc/get_value()
datum/pump_ui/proc/get_atom()

 // Checks user validity
datum/pump_ui/proc/validate_user(mob/user as mob)
	return !(user.stat || user.restrained())
 // Processes clicks on the links in the UI
datum/pump_ui/Topic(href, href_list)
	// boutput(world, "Received topic to pump ui: [list2params(href_list)]")
	if(!validate_user(usr))
		return
	if(href_list["ui_target"] == "pump_ui")
		if(href_list["ui_action"] == "set_value")
			var/value_to_set = input(usr, "[value_name] ([min_value] - [max_value] [value_units]):", "Enter new value", get_value()) as num
			if(isnum_safe(value_to_set))
				set_value(clamp(value_to_set, min_value, max_value))
		else if(href_list["ui_action"] == "toggle_power")
			toggle_power()
		else if(href_list["ui_action"] == "bump_value")
			set_value(clamp(get_value() + text2num_safe(href_list["bump_value"]), min_value, max_value))
	show_ui(usr)
 // Displays the UI
datum/pump_ui/proc/show_ui(mob/user)
	if (user.client.tooltipHolder)
		user.client.tooltipHolder.showClickTip(get_atom(), list("title" = src.pump_name, "content" = render()))

 // Generates the HTML
datum/pump_ui/proc/render()
	return {"
<span>[is_on() ? "Active" : "Inactive"]</span>
<a href="?src=\ref[src]&ui_target=pump_ui&ui_action=toggle_power">Toggle Power</a>
<br />
<span>[value_name]:
<a href="?src=\ref[src]&ui_target=pump_ui&ui_action=bump_value&bump_value=[-incr_lg]">-</a>
<a href="?src=\ref[src]&ui_target=pump_ui&ui_action=bump_value&bump_value=[-incr_sm]">-</a>
<a href="?src=\ref[src]&ui_target=pump_ui&ui_action=set_value">[get_value()] [value_units]</a>
<a href="?src=\ref[src]&ui_target=pump_ui&ui_action=bump_value&bump_value=[incr_sm]">+</a>
<a href="?src=\ref[src]&ui_target=pump_ui&ui_action=bump_value&bump_value=[incr_lg]">+</a>
"}
