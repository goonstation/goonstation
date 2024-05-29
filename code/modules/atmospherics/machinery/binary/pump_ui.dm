/datum/pump_ui
	/// Our pump's name, simple enough.
	var/pump_name
	/// The name of the value we use.
	var/value_name
	/// The units used by our value.
	var/value_units
 	/// The minimum our value can be.
	var/min_value
	/// The maximum our value can be.
	var/max_value
 	/// The amount to change by the small increment.
	var/incr_sm
	/// The amount to change by the large increment.
	var/incr_lg

// These need to be overridden in the children
/// What value to set arg to.
/datum/pump_ui/proc/set_value(value_to_set)
/// Toggle our pump's power.
/datum/pump_ui/proc/toggle_power()
/// Is our pump on?
/datum/pump_ui/proc/is_on()
/// Return value from our pump.
/datum/pump_ui/proc/get_value()
/// Return some atom from our pump.
/datum/pump_ui/proc/get_atom()

// Processes clicks on the links in the UI
/datum/pump_ui/Topic(href, href_list)
	if(!can_act(usr))
		return
	if(href_list["ui_target"] == "pump_ui")
		switch(href_list["ui_action"])
			if("set_value")
				var/value_to_set = input(usr, "[value_name] ([min_value] - [max_value] [value_units]):", "Enter new value", get_value()) as num
				if(isnum_safe(value_to_set))
					src.set_value(clamp(value_to_set, min_value, max_value))
					logTheThing(LOG_STATION, usr, "has set [src.get_atom()] value to [src.get_value()] at [log_loc(src.get_atom())]")

			if("toggle_power")
				src.toggle_power()
				logTheThing(LOG_STATION, usr, "has set [src.get_atom()] power to [src.is_on() ?  "On" : "Off"] at [log_loc(src.get_atom())]")

			if("bump_value")
				src.set_value(clamp(get_value() + text2num_safe(href_list["bump_value"]), min_value, max_value))
				logTheThing(LOG_STATION, usr, "has set [src.get_atom()] value to [src.get_value()] at [log_loc(src.get_atom())]")

	src.show_ui(usr)
/// Displays the UI
/datum/pump_ui/proc/show_ui(mob/user)
	if (user.client?.tooltipHolder) // Monke!
		user.client.tooltipHolder.showClickTip(get_atom(), list("title" = src.pump_name, "content" = render()))

/// Generates the HTML
/datum/pump_ui/proc/render()
	return {"
<span>[is_on() ? "Active" : "Inactive"]</span>
<a href="byond://?src=\ref[src]&ui_target=pump_ui&ui_action=toggle_power">Toggle Power</a>
<br />
<span>[value_name]:
<a href="byond://?src=\ref[src]&ui_target=pump_ui&ui_action=bump_value&bump_value=[-incr_lg]">-</a>
<a href="byond://?src=\ref[src]&ui_target=pump_ui&ui_action=bump_value&bump_value=[-incr_sm]">-</a>
<a href="byond://?src=\ref[src]&ui_target=pump_ui&ui_action=set_value">[get_value()] [value_units]</a>
<a href="byond://?src=\ref[src]&ui_target=pump_ui&ui_action=bump_value&bump_value=[incr_sm]">+</a>
<a href="byond://?src=\ref[src]&ui_target=pump_ui&ui_action=bump_value&bump_value=[incr_lg]">+</a>
"}
