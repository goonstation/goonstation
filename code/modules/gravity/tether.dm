ABSTRACT_TYPE(/obj/machinery/gravity_tether)
/obj/machinery/gravity_tether
	name = "gravity tether"
	desc = "A rather delicate piece of machinery that normalizes gravity to Earth-like levels."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "grav_tether_active"
	density = TRUE
	anchored = ANCHORED_ALWAYS
	bound_width = 64
	bound_height = 32
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	status = REQ_PHYSICAL_ACCESS
	layer = EFFECTS_LAYER_BASE // so it covers people who walk behind it
	speech_verb_say = list("bleeps", "bloops", "drones", "beeps", "boops", "emits")
	/// Are we currently active
	var/active = TRUE
	/// Can someone toggle us currently
	var/locked = FALSE
	/// Is this currently processing a gravity change
	var/working = FALSE
	/// How quickly are people allowed to change states
	var/cooldown = 15 SECONDS
	/// Delay between attempting to toggle and the effect atually changing
	var/delay = 10 SECONDS // needs to be shorter than cooldown
	/// Is this machine emagged
	var/emagged = FALSE
	/// List of target area references, populated on init
	var/list/area/target_area_refs = list()

/obj/machinery/gravity_tether/attack_hand(mob/user)
	if(..())
		return
	if(!in_interact_range(src, user))
		boutput(user, "You are too far away to reach the controls.")
		return
	if (src.working)
		src.say("Processing existing gravity shift.")
		return
	if (src.locked)
		src.say("Controls locked.")
		return
	var/cooldown_timer = GET_COOLDOWN(src, "gravity_toggle")
	if (cooldown_timer)
		src.say("Recalculating gravity matrix. [TO_SECONDS(cooldown_timer)] seconds remaining.")
		return
	if (tgui_alert(user, "Really [src.active ? "disable" : "enable"] [src]?", "Gravity Confirmation", list("Yes", "No")) == "Yes")
		// tgui_alert is async, so we need to check again
		cooldown_timer = GET_COOLDOWN(src, "gravity_toggle")
		if (cooldown_timer)
			src.say("Recalculating gravity matrix, [TO_SECONDS(cooldown_timer)] seconds remaining.")
			return
		src.say("Processing gravity change.")
		src.toggle(user)

/obj/machinery/gravity_tether/attackby(obj/item/I, mob/user)
	var/obj/item/card/id/id_card = get_id_card(I)
	if (istype(id_card) && length(src.req_access))
		if (src.allowed(user))
			src.locked = !src.locked
			src.say("Interface [src.locked ? "locked" : "unlocked"].")
			if (!src.locked)
				logTheThing(LOG_STATION, user, "unlocked gravity tether at at [log_loc(src)].")
		else
			src.say("Access denied.")
		return
	. = ..()

/obj/machinery/gravity_tether/emag_act(mob/user, obj/item/card/emag/E)
	. = ..()
	if(src.emagged)
		boutput(user, "It looks like [src] is already glitching out...")
		return
	logTheThing(LOG_STATION, src, "was emagged by [user] at [log_loc(src)].")
	boutput(user, "You slide [E] across [src]'s ID reader.")
	src.emagged = TRUE
	src.random_fault(69) // chaos reigns

//TODO: Way to remove emagged state
/obj/machinery/gravity_tether/demag(mob/user)
	. = ..()
	src.emagged = FALSE

/obj/machinery/gravity_tether/overload_act()
	. = ..()
	if (!ON_COOLDOWN(src, "overload_cooldown", 5 MINUTES))
		src.visible_message("The pylons on [src] short together!")
		src.random_fault(3)
		return TRUE
	return FALSE

/obj/machinery/gravity_tether/set_broken()
	. = ..()
	src.random_fault(20)

/obj/machinery/gravity_tether/proc/toggle(mob/user)
	if (src.working)
		return
	logTheThing(LOG_STATION, user, "toggled [src] to [src.active ? "disabled" : "enabled"] at [log_loc(src)]")
	src.working = TRUE
	SPAWN(delay)
		src.working = FALSE
		src.say("Gravity field [src.active ? "disabled" : "enabled"].")
		OVERRIDE_COOLDOWN(src, "gravity_toggle", src.cooldown)
		if (src.active)
			src.deactivate()
			return
		src.activate()

/obj/machinery/gravity_tether/proc/activate()
	src.active = TRUE
	src.icon_state = "grav_tether_active"
	if(src.emagged)
		src.random_fault()
	for (var/area/A in src.target_area_refs)
		A.has_gravity = TRUE
	for(var/client/C in clients)
		var/mob/M = C.mob
		if(M?.z == src.z) shake_camera(M, 5, 32, 0.2)

/obj/machinery/gravity_tether/proc/deactivate()
	src.active = FALSE
	src.icon_state = "grav_tether_disabled"
	if(src.emagged)
		src.random_fault()
	for (var/area/A in src.target_area_refs)
		A.has_gravity = FALSE
	for(var/client/C in clients)
		var/mob/M = C.mob
		if(M?.z == src.z) shake_camera(M, 5, 32, 0.2)

/*
Fault effects have an area parameter, and return a number inidcating the severity of what occurred.
This is so we can mix high-impact and low-impact effects without completely overwhelming the station
*/

/// When a fault should occur, roll random faults up to the severity of the
/obj/machinery/gravity_tether/proc/random_fault(severity_points = 1)
	if (!isnum(severity_points))
		logTheThing(LOG_DEBUG, src, "random fault proc called with non-number severity points, aborting.")
		return
	while (severity_points > 0)
		var/area/A = pick(src.target_area_refs)
		switch(rand(1, 3))
			if(1)
				severity_points -= src.gravity_spike(A)
			if(2)
				severity_points -= src.toggle_gravity(A)
			if(3)
				severity_points -= src.form_hole(A)

/// TETHER FAULT: Knock and slow down people in an area
/obj/machinery/gravity_tether/proc/gravity_spike(area/A)
	. = 1
	logTheThing(LOG_STATION, src, "triggered a gravity spike in [A].")
	for (var/mob/M in A.population)
		shake_camera(M, 5, 32, 0.2)
		if (M.client)
			boutput(M, SPAN_ALERT("You suddenly feel heavy..."))
		M.changeStatus("knockdown", 2 SECONDS)
		M.changeStatus("staggered_gravity", 15 SECONDS)

/// TETHER FAULT: Toggle gravity in an area
/obj/machinery/gravity_tether/proc/toggle_gravity(area/A)
	. = 1
	logTheThing(LOG_STATION, src, "reversed gravity in [A].")
	A.has_gravity = !A.has_gravity

/// TETHER FAULT: Forms a white or black hole in an area
/obj/machinery/gravity_tether/proc/form_hole(area/A)
	. = 20
	var/list/turfs = get_area_turfs(A, floors_only = TRUE)
	if (!length(turfs)) // if no floors, try all turfs
		turfs = get_area_turfs(A, floors_only = FALSE)
	if (!length(turfs)) // we got an area with no turfs, somehow, bail
		logTheThing(LOG_DEBUG, src, "failed to form a white/black hole in area [A.name] due to no turfs inside.")
		return 0
	var/turf/T = pick(turfs)
	var/hole_type
	if (prob(50))
		hole_type = "white hole"
		new /obj/whitehole(T)
	else
		hole_type = "black hole"
		new /obj/anomaly/bhole_spawner(T)
	logTheThing(LOG_STATION, src, "spawned a [hole_type] at [log_loc(T)].")

/obj/machinery/gravity_tether/station
	req_access = list(access_engineering_chief)
	cooldown = 60 SECONDS
	locked = TRUE

/obj/machinery/gravity_tether/station/New()
	. = ..()
	src.desc += " This one appears to control gravity on the entire [station_or_ship()]."

/obj/machinery/gravity_tether/station/initialize()
	. = ..()
	var/list/areas = get_accessible_station_areas()
	for (var/area_name in areas)
		src.target_area_refs += areas[area_name]

/obj/machinery/gravity_tether/station/activate()
	. = ..()
	if(src.emagged)
		return
	for(var/client/C in clients)
		var/mob/M = C.mob
		if(M?.z == src.z) shake_camera(M, 5, 32, 0.2)
	for(var/area_name in get_accessible_station_areas())
		station_areas[area_name].has_gravity = TRUE

/obj/machinery/gravity_tether/station/deactivate()
	. = ..()
	if(src.emagged)
		return
	for(var/client/C in clients)
		var/mob/M = C.mob
		if(M?.z == src.z) shake_camera(M, 5, 32, 0.2)
	for(var/area_name in get_accessible_station_areas())
		station_areas[area_name].has_gravity = FALSE

/obj/machinery/gravity_tether/station/toggle(mob/user)
	command_alert("[src] aboard [station_name] will [src.active ? "deactivate" : "activate"] shortly. All crew are recommended to brace for a sudden change in local gravity.", "Gravity Tether Alert", alert_origin = ALERT_STATION)
	logTheThing(LOG_STATION, user, "[src.active ? "disabled" : "enabled"] station gravity tether at at [log_loc(src)].")
	. = ..()


// TODO: TYPEINFO for mech scanning
/obj/machinery/gravity_tether/current_area
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "lockdown_safe" //TODO: 32x32 sprite
	bound_width = 32
	bound_height = 32

/obj/machinery/gravity_tether/current_area/initialize()
	. = ..()
	// TODO: check for other tethers controlling this area
	// check if station area, then check if there's a tether in the current area
	// might need to track multi-area tethers to cross-check those
	src.target_area_refs += get_area(src)

/obj/machinery/gravity_tether/current_area/activate()
	. = ..()
	var/area/A = get_area(src)
	for (var/mob/M in A)
		if (M.client)
			shake_camera(M, 5, 32, 0.2)
	A.has_gravity = TRUE

/obj/machinery/gravity_tether/current_area/deactivate()
	. = ..()
	var/area/A = get_area(src)
	for (var/mob/M in A)
		if (M.client)
			shake_camera(M, 5, 32, 0.2)
	A.has_gravity = FALSE

/obj/machinery/gravity_tether/current_area/attackby(obj/item/I, mob/user)
	. = ..()
	// TODO: Anchor/unanchor via wrench when off?
	// TODO: Mechanics deconstruction?
	// Need to re-configure the area ref var


ABSTRACT_TYPE(/obj/machinery/gravity_tether/multi_area)
/obj/machinery/gravity_tether/multi_area
	///List of area typepaths this machine should control.
	var/list/area_typepaths = list()

/obj/machinery/gravity_tether/multi_area/initialize()
	. = ..()
	for (var/area_typepath in src.area_typepaths)
		var/area/A = get_area_by_type(area_typepath)
		if (istype(A))
			src.target_area_refs.Add(A)
