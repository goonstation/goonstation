/datum/buildmode/gravity
	name = "Gravity"
	desc = {"**************************************************************<br>
Use `debug-overlay gravity` to see gravity values<br>
Left Click on turf	- Set turf gravity override<br>
Ctrl + Left Click on turf - Reset turf gravity override<br>
Right Click on turf	- Set area minimum gravity<br>
Right Click on Buildmode Button	- Set gravity value to apply on left-click<br>
Ctrl + Right Click on Buildmode Button	- Change Z-level gravity values<br>
**************************************************************"}
	icon_state = "buildmode_putin"
	var/gforce_value = GFORCE_EARTH_GRAVITY

	New(datum/buildmode_holder/H)
		. = ..()
		update_button_text("[src.gforce_value/GFORCE_EARTH_GRAVITY]G")


	click_mode_right(ctrl, alt, shift)
		if (ctrl)
			var/zlevel_to_alter = tgui_input_number(usr, "Which Z-level to change gravity on?", "Enter Z-Level", Z_LEVEL_STATION, world.maxz, 1)
			if (isnull(zlevel_to_alter))
				return
			if (!isnum(zlevel_to_alter) || zlevel_to_alter < 1 || zlevel_to_alter > world.maxz)
				boutput(usr, SPAN_ALERT("No matching Z-level '[zlevel_to_alter]'!"))
				return
			var/gforce_to_set = tgui_input_number(usr, "How much gravity should Z-Level '[zlevel_to_alter]' have minimum, in G-Force?", "Z-level G-Force", GFORCE_EARTH_GRAVITY/GFORCE_EARTH_GRAVITY, 1000, 0, round_input=FALSE)
			if (isnull(gforce_to_set) || gforce_to_set == "")
				return
			if (!isnum(gforce_to_set) || gforce_to_set < 0)
				boutput(usr, SPAN_ALERT("Invalid G-force setting '[gforce_to_set]'"))
				return
			gforce_to_set *= GFORCE_EARTH_GRAVITY
			var/update_tethers = tgui_alert(usr, "Tell gravity tethers on same z-level to update?", "Tether Update", list("Yes", "No")) == "Yes"

			var/confirm = tgui_alert(usr, "Set Z-level '[zlevel_to_alter]' to [gforce_to_set/GFORCE_EARTH_GRAVITY]G, and [update_tethers ? "" :"do not "]update tethers", "Confirm", list("Confirm", "Cancel")) == "Confirm"
			if (confirm)
				global.set_zlevel_gforce(zlevel_to_alter, gforce_to_set, update_tethers)
		else
			var/gforce_to_set = tgui_input_number(usr, "How much gravity should left-clicking set turf gravity to, in G-Force?", "Turf G-Force", src.gforce_value/GFORCE_EARTH_GRAVITY, 1000, 0, round_input=FALSE)
			if (isnull(gforce_to_set) || gforce_to_set == "")
				return
			if (!isnum(gforce_to_set) || gforce_to_set < 0)
				boutput(usr, SPAN_ALERT("Invalid G-force setting '[gforce_to_set]'"))
				return
			src.gforce_value = gforce_to_set * GFORCE_EARTH_GRAVITY
			update_button_text("[src.gforce_value/GFORCE_EARTH_GRAVITY]G")
		. = ..()

	click_left(atom/object, ctrl, alt, shift)
		. = ..()
		var/turf/T = get_turf(object)
		if (!istype(T))
			return
		if (ctrl)
			T.clear_gforce_override()
		else
			T.set_gforce_override(src.gforce_value)

	click_right(atom/object, ctrl, alt, shift)
		. = ..()
		var/area/A = get_area(object)
		if (!istype(A))
			return
		if (istype(A, /area/space))
			boutput(usr, SPAN_ALERT("This tile's area is /area/space - make a new area or change Z-level gravity instead!"))
			return
		var/gforce_to_set = tgui_input_number(usr, "Minimum gravity for area '[A]' have, in G-Force?", "G-Force Minimum", A.gforce_minimum/GFORCE_EARTH_GRAVITY, 1000, 0, round_input=FALSE)
		if (isnull(gforce_to_set) || gforce_to_set == "")
			return
		if (!isnum(gforce_to_set) || gforce_to_set < 0)
			boutput(usr, SPAN_ALERT("Invalid G-force setting '[gforce_to_set]'"))
			return

		var/confirm = tgui_alert(usr, "Set Area '[A]' minimum gravity to [gforce_to_set]?", "Confirm", list("Confirm", "Cancel")) == "Confirm"
		if (confirm)
			A.set_gforce_minimum(gforce_to_set * 100)
