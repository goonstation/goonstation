/obj/machinery/gravity_tether/station
	name = "\improper Gravi-Tonne wide-area gravity tether"
	icon = 'icons/obj/machines/tether_64x64.dmi'
	icon_state = "base"
	bound_width = 64 // wide
	bound_height = 32 // but not long
	// oversize sprite, so move the speak textbox
	maptext_manager_x = 16
	maptext_manager_y = 16
	req_access = list(access_engineering_chief)
	active_wattage_per_g = 1 MEGA WATT
	passive_wattage_per_g = 10 KILO WATTS
	cooldown = 60 SECONDS
	locked = TRUE
	replacable_cell = TRUE

/obj/machinery/gravity_tether/station/New()
	src.RegisterSignal(GLOBAL_SIGNAL, COMSIG_GRAVITY_DISTURBANCE, /obj/machinery/gravity_tether/station/proc/on_gravity_disturbance)
	src.desc += " This one appears to control gravity on the entire [station_or_ship()]."
	var/list/station_area_names = get_accessible_station_areas()
	var/list/area_types_to_skip = global.z_level_station_outside_area_types
	area_types_to_skip |= global.map_settings.station_tether_ignore_area_types
	area_types_to_skip |= global.map_settings.ai_satellite_area_types

	var/list/target_areas = list()
	for (var/area_name in station_area_names)
		target_areas += station_areas[area_name]

	var/list/skipped_areas = list()
	for (var/area_type in area_types_to_skip)
		skipped_areas += get_areas(area_type)

	src.target_area_refs = target_areas - skipped_areas

	if (global.map_setting == "DONUT3") // donut3 has an indoor escape area
		src.target_area_refs += /area/shuttle/escape/station

	var/area/A = get_area(src)
	if (!istype (A, /area/station))
		src.intensity = 0
		src.target_intensity = 0

	. = ..()

/obj/machinery/gravity_tether/station/disposing()
	src.UnregisterSignal(src, COMSIG_GRAVITY_DISTURBANCE)
	. = ..()

/obj/machinery/gravity_tether/station/update_icon()
	src.ClearAllOverlays(TRUE)

	src.AddOverlays(SafeGetOverlayImage("graviton", 'icons/obj/machines/tether_64x64.dmi', "graviton-idle"), "graviton")

	// maintenance panel
	switch (src.door_state)
		if (TETHER_DOOR_WELDED)
			src.AddOverlays(SafeGetOverlayImage("door", 'icons/obj/machines/tether_64x64.dmi', "door-closed"), "door")
			src.AddOverlays(SafeGetOverlayImage("door", 'icons/obj/machines/tether_64x64.dmi', "door-welded-overlay"), "dooweld")
		if (TETHER_DOOR_CLOSED)
			src.AddOverlays(SafeGetOverlayImage("door", 'icons/obj/machines/tether_64x64.dmi', "door-closed"), "door")
		if (TETHER_DOOR_OPEN, TETHER_DOOR_MISSING)
			if (src.cell)
				var/image/battery_image
				if (src.cell.artifact)
					battery_image = SafeGetOverlayImage("cell", 'icons/obj/power.dmi', "apc-[src.cell.artifact.artiappear.name]", pixel_x = 10, pixel_y = 5)
				else
					battery_image = SafeGetOverlayImage("cell", 'icons/obj/power.dmi', "apc-[src.cell.icon_state]", pixel_x = 10, pixel_y = 5)
				src.AddOverlays(battery_image, "cell")

				// battery charge indicator
				if(!src.cell.specialicon)
					var/image/battery_charge_overlay = SafeGetOverlayImage("charge_indicator", 'icons/obj/power.dmi', "cell-o2", pixel_x = 11, pixel_y = 6)
					if(src.cell.charge < 0.01)
						src.ClearSpecificOverlays(TRUE, "charge_indicator")
					else if(src.cell.charge/src.cell.maxcharge >=0.995)
						battery_charge_overlay.icon_state = "cell-o2"
						src.AddOverlays(battery_charge_overlay, "charge_indicator")
					else
						battery_charge_overlay.icon_state = "cell-o1"
						src.AddOverlays(battery_charge_overlay, "charge_indicator")


			else // wire overlay is completely hidden by the battery
				switch (src.wire_state)
					if (TETHER_WIRES_INTACT)
						src.AddOverlays(SafeGetOverlayImage("wires", 'icons/obj/machines/tether_64x64.dmi', "wires-intact"), "wires")
					if (TETHER_WIRES_BURNED)
						src.AddOverlays(SafeGetOverlayImage("wires", 'icons/obj/machines/tether_64x64.dmi', "wires-burned"), "wires")
					if (TETHER_WIRES_CUT)
						src.AddOverlays(SafeGetOverlayImage("wires", 'icons/obj/machines/tether_64x64.dmi', "wires-cut"), "wires")

			// tamper grate layers above battery/wires
			if (!src.locked)
				src.AddOverlays(SafeGetOverlayImage("tamper", 'icons/obj/machines/tether_64x64.dmi', "tamper-raised"), "tamper")
			else
				if (src.tamper_intact)
					src.AddOverlays(SafeGetOverlayImage("tamper", 'icons/obj/machines/tether_64x64.dmi', "tamper-secure"), "tamper")
				else
					src.AddOverlays(SafeGetOverlayImage("tamper", 'icons/obj/machines/tether_64x64.dmi', "tamper-cut"), "tamper")
			if (src.door_state == TETHER_DOOR_OPEN)
				src.AddOverlays(SafeGetOverlayImage("door", 'icons/obj/machines/tether_64x64.dmi', "door-open"), "door")

	if (src.has_no_power())
		src.light.disable()
		return

	var/color_r = 0
	var/color_g = 0
	var/color_b = 0

	// gravity ball
	if (src.is_broken())
		src.UpdateOverlays(SafeGetOverlayImage("graviton", 'icons/obj/machines/tether_64x64.dmi', "graviton-wonky"), "graviton")
		color_r += 100
		color_b += 100
	else
		src.UpdateOverlays(SafeGetOverlayImage("graviton", 'icons/obj/machines/tether_64x64.dmi', "graviton-nominal"), "graviton")
		color_r += 50
		color_b += 50

	// histogram
	if (!src.is_broken())
		if (src.gravity_disturbed_until)
			src.AddOverlays(SafeGetOverlayImage("histogram", 'icons/obj/machines/tether_64x64.dmi', "graph-bad"), "histogram")
			color_r += 10
		else
			if (src.intensity > 0)
				src.AddOverlays(SafeGetOverlayImage("histogram", 'icons/obj/machines/tether_64x64.dmi', "graph-good"), "histogram")
				color_g += 10
			else
				src.AddOverlays(SafeGetOverlayImage("histogram", 'icons/obj/machines/tether_64x64.dmi', "graph-okay"), "histogram")
				color_r += 5
				color_g += 5

	// computer screen
	if (src.locked)
		src.AddOverlays(SafeGetOverlayImage("screen", 'icons/obj/machines/tether_64x64.dmi',"screen-locked"), "screen")
		color_r += 5
		color_g += 5
	else
		src.AddOverlays(SafeGetOverlayImage("screen", 'icons/obj/machines/tether_64x64.dmi',"screen-unlocked"), "screen")
		color_g += 10

	// charge lights
	if (src.cell)
		switch (src.cell.percent())
			if (0 to 5)
				src.AddOverlays(SafeGetOverlayImage("charge_amount", 'icons/obj/machines/tether_64x64.dmi',"battery-critical"), "charge_amount")
			if (5 to 25)
				src.AddOverlays(SafeGetOverlayImage("charge_amount", 'icons/obj/machines/tether_64x64.dmi',"battery-low"), "charge_amount")
				color_r += 30
			if (25 to 70)
				src.AddOverlays(SafeGetOverlayImage("charge_amount", 'icons/obj/machines/tether_64x64.dmi',"battery-medium"), "charge_amount")
				color_r += 20
				color_g += 10
			if (70 to 95)
				src.AddOverlays(SafeGetOverlayImage("charge_amount", 'icons/obj/machines/tether_64x64.dmi',"battery-high"), "charge_amount")
				color_g += 30
			if (95 to 100)
				src.AddOverlays(SafeGetOverlayImage("charge_amount", 'icons/obj/machines/tether_64x64.dmi',"battery-full"), "charge_amount")
				color_r += 10
				color_g += 10
				color_b += 15

		switch(src.charge_state)
			if (TETHER_CHARGE_CHARGING)
				src.AddOverlays(SafeGetOverlayImage("charge_state", 'icons/obj/machines/tether_64x64.dmi', "power-charging"), "charge_state")
			if (TETHER_CHARGE_DRAINING)
				src.AddOverlays(SafeGetOverlayImage("charge_state", 'icons/obj/machines/tether_64x64.dmi', "power-discharging"), "charge_state")
	else
		src.AddOverlays(SafeGetOverlayImage("charge_amount", 'icons/obj/machines/tether_64x64.dmi',"battery-critical"), "charge_amount")
		color_r += 5

	// status lights
	if (src.changing_gravity)
		src.AddOverlays(SafeGetOverlayImage("status", 'icons/obj/machines/tether_64x64.dmi', "status-processing"), "status")
		color_r += 10
		color_g += 10
		color_b += 15
	else if (src.is_broken())
		src.AddOverlays(SafeGetOverlayImage("status", 'icons/obj/machines/tether_64x64.dmi', "status-broken"), "status")
		color_r += 30
	else if (src.intensity > 0)
		src.AddOverlays(SafeGetOverlayImage("status", 'icons/obj/machines/tether_64x64.dmi', "status-working"), "status")
		color_g += 30
	else
		src.AddOverlays(SafeGetOverlayImage("status", 'icons/obj/machines/tether_64x64.dmi', "status-idle"), "status")
		color_r += 20
		color_g += 10

	// intensity lights
	switch(src.intensity)
		if (1)
			src.AddOverlays(SafeGetOverlayImage("intensity", 'icons/obj/machines/tether_64x64.dmi', "level-2"), "intensity")
			color_b += 20
		if (-INFINITY to 0)
			src.AddOverlays(SafeGetOverlayImage("intensity", 'icons/obj/machines/tether_64x64.dmi', "level-0"), "intensity")
		if (0 to 0.5)
			src.AddOverlays(SafeGetOverlayImage("intensity", 'icons/obj/machines/tether_64x64.dmi', "level-1"), "intensity")
			color_b += 10
		if (0.5 to 1)
			src.AddOverlays(SafeGetOverlayImage("intensity", 'icons/obj/machines/tether_64x64.dmi', "level-2"), "intensity")
			color_b += 20
		if (1 to 1.5)
			src.AddOverlays(SafeGetOverlayImage("intensity", 'icons/obj/machines/tether_64x64.dmi', "level-3"), "intensity")
			color_b += 30
		if (1.5 to INFINITY)
			src.AddOverlays(SafeGetOverlayImage("intensity", 'icons/obj/machines/tether_64x64.dmi', "level-4"), "intensity")
			color_b += 40

	// dials
	if (src.changing_gravity)
		if (src.target_intensity > src.intensity)
			src.AddOverlays(SafeGetOverlayImage("dials", 'icons/obj/machines/tether_64x64.dmi', "dials-spinup"), "dials")
		else
			src.AddOverlays(SafeGetOverlayImage("dials", 'icons/obj/machines/tether_64x64.dmi', "dials-spindown"), "dials")
	else
		if (src.is_broken())
			src.AddOverlays(SafeGetOverlayImage("dials", 'icons/obj/machines/tether_64x64.dmi', "dials-wild"), "dials")
		else
			src.AddOverlays(SafeGetOverlayImage("dials", 'icons/obj/machines/tether_64x64.dmi', "dials-regular"), "dials")

	src.light.set_color(color_r/255, color_g/255, color_b/255)
	src.light.enable()

/obj/machinery/gravity_tether/station/attempt_gravity_change(new_intensity)
	var/area/A = get_area(src)
	if (!istype (A, /area/station))
		return
	. = ..()

/obj/machinery/gravity_tether/station/begin_gravity_change(new_intensity)
	// emagging or a nearby signal-blocker stops the announcement
	if (!src.emagged && !check_for_radio_jammers(src))
		command_alert("The [station_or_ship()]-wide gravity tether is shifting to [new_intensity]G. Brace for sudden gravity shift within [src.cooldown] seconds.", "Gravity Tether Warning", alert_origin = ALERT_STATION)
	. = ..()

/obj/machinery/gravity_tether/station/change_intensity(new_intensity)
	if (..())
		return TRUE
	for(var/client/C in clients)
		var/mob/M = C.mob
		if(M?.z == src.z)
			shake_camera(M, 5, 32, 0.2)
	for_by_tcl(airbridge, /obj/airbridge_controller)
		for (var/turf/T in airbridge.maintaining_turfs)
			T.update_gravity()

/obj/machinery/gravity_tether/station/cell_rig_effect()
	. = ..()
	for(var/client/C in clients)
		if (C.mob.z == src.z)
			playsound(C.mob, 'sound/effects/explosionfar.ogg', 35, 0)

// check under both tether tiles
/obj/machinery/gravity_tether/station/get_power_wire()
	var/obj/cable/C = null
	for (var/obj/cable/candidate in get_step(src, EAST))
		if (!candidate.d1)
			C = candidate
			break
	if (C)
		return C
	else
		return ..()

/obj/machinery/gravity_tether/station/proc/on_gravity_disturbance(_)
	if (src.is_disabled())
		return
	if (!ON_COOLDOWN(src, "gravity_disturbance", 60 SECONDS))
		src.gravity_disturbed_until = TIME + 60 SECONDS
		playsound(src.loc, 'sound/effects/manta_alarm.ogg', 50, 1)
		src.say("Gravity disturbance detected.")
		src.UpdateIcon()
