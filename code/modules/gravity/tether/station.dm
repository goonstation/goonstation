/// Combined value of all station gravity tether gforces
///
/// Needed so airbridge controllers can set gravity on their controlled turfs
var/global/station_tether_gforce = 0

TYPEINFO(/obj/machinery/gravity_tether)
	mats = null
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
	locked = TRUE

/obj/machinery/gravity_tether/station/New()
	src.desc += " This one appears to control gravity on the entire [station_or_ship()]."
	. = ..()
	src.ma_cell.pixel_x = 10
	src.ma_cell.pixel_y = 5
	src.light.attach(src, 1, 0.5) // light has height
	src.update_light()

/obj/machinery/gravity_tether/station/initialize()
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
		src.target_area_refs += get_area_by_type(/area/shuttle/escape/station)
	. = ..()

/obj/machinery/gravity_tether/station/get_desc(dist, mob/user)
	. = ..()
	switch (src.door_state)
		if (TETHER_DOOR_OPEN, TETHER_DOOR_MISSING)
			if (src.door_state == TETHER_DOOR_MISSING)
				. += "<br>The maintenance door is missing completely!"
			if (src.locked)
				if (src.tamper_intact)
					. += "<br>The tamper-resist grate is down."
				else
					. += "<br>The tamper-resist grate has been sliced through!"
			if (src.cell)
				. += "<br>The internal capacitor cell is installed and is at [round(src.cell.percent())]% charge."
			else
				. += "<br>There is no internal capcaitor cell installed, "
				switch (src.wire_state)
					if (TETHER_WIRES_INTACT)
						. += " but the wiring looks intact."
					if (TETHER_WIRES_BURNED)
						. += " and the wiring is melted together!"
					if (TETHER_WIRES_CUT)
						. += " and the wiring has been cut out!"
		if (TETHER_DOOR_WELDED)
			. += "<br>The maintenance door is welded shut!"

/obj/machinery/gravity_tether/station/attempt_gravity_change(new_intensity)
	var/area/A = get_area(src)
	if (!istype (A, /area/station))
		return
	. = ..()

/obj/machinery/gravity_tether/station/begin_gravity_change(new_intensity)
	. = ..()
	if (src.do_announcement && !global.check_for_radio_jammers(src)) // TODO: Make this a real packet to the announcement computer
		command_alert("The [station_or_ship()]-wide gravity tether will begin shifting to [new_intensity]G in [time_to_text(src.change_begin_time-TIME)].", "Gravity Change Warning", alert_origin = ALERT_STATION)
	else // reset for next person
		src.do_announcement = TRUE

/obj/machinery/gravity_tether/station/shake_affected()
	for(var/client/C in clients)
		var/mob/M = C.mob
		if(M?.z == src.z)
			shake_camera(M, 5, 32, 0.2)

/obj/machinery/gravity_tether/station/change_intensity(new_intensity)
	var/diff = new_intensity - src.gforce_intensity
	if (..())
		return TRUE
	if (diff == 0)
		return
	global.station_tether_gforce += diff
	for_by_tcl(airbridge, /obj/airbridge_controller)
		for (var/turf/T in airbridge.maintaining_turfs)
			T.update_gforce_inherent(global.station_tether_gforce)

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

// from /particles/rack_spark
/particles/station_tether_spark
	icon = 'icons/effects/lines.dmi'
	icon_state = list("lght")
	color = "#ffffff"
	spawning = 0.1
	count = 20
	lifespan = generator("num", 1, 3, UNIFORM_RAND)
	fade = 0
	position = generator("box", list(-16,-20,0), list(16,32,0), UNIFORM_RAND)
	velocity = list(0, 0, 0)
	gravity = list(0, 0, 0)
	scale = generator("box", list(0.1,0.1,1), list(0.3,0.3,1), UNIFORM_RAND)
	rotation = generator("num", 0, 360, UNIFORM_RAND)
	grow = list(0.01, 0)
	fadein = 0
