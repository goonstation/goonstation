#define TETHER_EMAG_CHANGE_CHANCE 50
#define TETHER_EMAG_CHANGE_COUNT 20

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
		return
	boutput(user, "You slide [E] across [src]'s ID reader.")
	src.emagged = TRUE
	src.ensure_speech_tree().AddSpeechModifier(SPEECH_MODIFIER_ACCENT_SWEDISH)
	src.emag_effect()

//TODO: Way to remove emagged state
/obj/machinery/gravity_tether/demag(mob/user)
	. = ..()
	src.emagged = FALSE
	src.ensure_speech_tree().RemoveSpeechModifier(SPEECH_MODIFIER_ACCENT_SWEDISH)

/obj/machinery/gravity_tether/proc/toggle(mob/user)
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
		src.emag_effect()
		return
	for (var/area/A in src.target_area_refs)
		A.has_gravity = TRUE
	for(var/client/C in clients)
		var/mob/M = C.mob
		if(M?.z == src.z) shake_camera(M, 5, 32, 0.2)

/obj/machinery/gravity_tether/proc/deactivate()
	src.active = FALSE
	src.icon_state = "grav_tether_disabled"
	if(src.emagged)
		src.emag_effect()
		return
	for (var/area/A in src.target_area_refs)
		A.has_gravity = FALSE
	for(var/client/C in clients)
		var/mob/M = C.mob
		if(M?.z == src.z) shake_camera(M, 5, 32, 0.2)

/obj/machinery/gravity_tether/proc/emag_effect()
	if (prob(50))
		src.gravity_spike()
	else
		src.random_gravity()

/obj/machinery/gravity_tether/proc/gravity_spike()
	var/changed_area_count = 0
	var/max_changes = min(TETHER_EMAG_CHANGE_COUNT, length(src.target_area_refs))
	while (changed_area_count < max_changes)
		var/area/A = pick(src.target_area_refs)
		for (var/mob/M in A)
			boutput(M, SPAN_ALERT("You feel so heavy..."))
			M.changeStatus("knockdown", 3 SECONDS)
		changed_area_count += 1

///Flips gravity randomly
/obj/machinery/gravity_tether/proc/random_gravity()
	var/changed_area_count = 0
	var/max_changes = min(TETHER_EMAG_CHANGE_COUNT, length(src.target_area_refs))
	while (changed_area_count < max_changes)
		var/area/A = pick(src.target_area_refs)
		A.has_gravity = !A.has_gravity
		changed_area_count += 1


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
		src.emag_effect()
		return
	for(var/client/C in clients)
		var/mob/M = C.mob
		if(M?.z == src.z) shake_camera(M, 5, 32, 0.2)
	for(var/area_name in get_accessible_station_areas())
		station_areas[area_name].has_gravity = TRUE

/obj/machinery/gravity_tether/station/deactivate()
	. = ..()
	if(src.emagged)
		src.emag_effect()
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


#undef TETHER_EMAG_CHANGE_CHANCE
#undef TETHER_EMAG_CHANGE_COUNT
