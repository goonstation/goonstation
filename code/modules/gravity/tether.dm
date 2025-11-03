#define TETHER_EMAG_CHANGE_CHANCE 50
#define TETHER_EMAG_CHANGE_COUNT 20

ABSTRACT_TYPE(/obj/machinery/gravity_tether)
/obj/machinery/gravity_tether
	name = "gravity tether"
	desc = "A rather delicate piece of machinery that normalizes gravity to Earth-like levels."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "magbeacon"
	density = TRUE
	anchored = ANCHORED_ALWAYS
	bound_width = 32
	bound_height = 32
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	status = REQ_PHYSICAL_ACCESS
	speech_verb_say = list("bleeps", "bloops", "drones", "beeps", "boops", "emits")
	/// Are we currently active
	var/active = TRUE
	/// Can someone toggle us currently
	var/locked = FALSE
	/// Is this currently processing a gravity change
	var/working = FALSE
	/// How quickly are people allowed to change toggle the active state
	var/cooldown = 15 SECONDS
	/// Is this machine emagged
	var/emagged = FALSE

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
		src.say("Recalculating gravity matrix, [TO_SECONDS(cooldown_timer)] seconds remaining.")
		return
	if (tgui_alert(user, "Really [src.active ? "disable" : "enable"] [src]?", "Gravity Confirmation", list("Yes", "No")) == "Yes")
		// tgui_alert is async, so we need to check again
		cooldown_timer = GET_COOLDOWN(src, "gravity_toggle")
		if (cooldown_timer)
			src.say("Recalculating gravity matrix, [TO_SECONDS(cooldown_timer)] seconds remaining.")
			return
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

/obj/machinery/gravity_tether/proc/toggle(mob/user)
	src.say("Tether [src.active ? "disabled" : "enabled"]. Have a nice day!")
	OVERRIDE_COOLDOWN(src, "gravity_toggle", src.cooldown)
	if (src.active)
		src.deactivate()
		return
	src.activate()

/obj/machinery/gravity_tether/proc/activate()
	src.active = TRUE
	src.icon_state = "magbeacon"

/obj/machinery/gravity_tether/proc/deactivate()
	src.active = FALSE
	src.icon_state = "magbeacon_off"

/obj/machinery/gravity_tether/station
	req_access = list(access_engineering_chief)
	cooldown = 60 SECONDS
	locked = TRUE
	/// Delay between attempting to toggle and the effect atually changing
	var/delay = 10 SECONDS // needs to be shorter than cooldown

/obj/machinery/gravity_tether/station/New()
	. = ..()
	src.desc += " This one appears to control gravity on the entire [station_or_ship()]."

/obj/machinery/gravity_tether/station/emag_act(mob/user, obj/item/card/emag/E)
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

/obj/machinery/gravity_tether/station/toggle(mob/user)
	command_alert("[src] aboard [station_name] will [src.active ? "deactivate" : "activate"] shortly. All crew are recommended to brace for a sudden change in local gravity.", "Gravity Tether Alert", alert_origin = ALERT_STATION)
	logTheThing(LOG_STATION, user, "[src.active ? "disabled" : "enabled"] gravity tether at at [log_loc(src)].")
	src.working = TRUE
	SPAWN(delay)
		. = ..()
		src.working = FALSE

/obj/machinery/gravity_tether/station/activate()
	. = ..()
	if(src.emagged)
		src.emag_effect()
		return
	for(var/area_name in get_accessible_station_areas())
		station_areas[area_name].has_gravity = TRUE

/obj/machinery/gravity_tether/station/deactivate()
	. = ..()
	if(src.emagged)
		src.emag_effect()
		return
	for(var/area_name in get_accessible_station_areas())
		station_areas[area_name].has_gravity = FALSE

/// Makes gravity "swiss cheese" across the station
/obj/machinery/gravity_tether/station/proc/emag_effect()
	var/changed_area_count = 0
	for(var/area_name in get_accessible_station_areas())
		// we do little a picking on genetics, as a treat
		if (prob(TETHER_EMAG_CHANGE_CHANCE) || istype(station_areas[area_name], /area/station/medical/research))
			changed_area_count += 1
			station_areas[area_name].has_gravity = !station_areas[area_name].has_gravity
			if(changed_area_count >= TETHER_EMAG_CHANGE_COUNT)
				break

/obj/machinery/gravity_tether/current_area
	req_access = list()

/obj/machinery/gravity_tether/current_area/activate()
	var/area/A = get_area(src)
	A.has_gravity = TRUE

/obj/machinery/gravity_tether/current_area/deactivate()
	var/area/A = get_area(src)
	A.has_gravity = FALSE

ABSTRACT_TYPE(/obj/machinery/gravity_tether/multi_area)
/obj/machinery/gravity_tether/multi_area
	///List of area typepaths this machine should control. You should make a subtype instead of map varediting.
	var/list/area_typepaths = list()
	/// Dynamically generated list of area refs at runtime
	var/list/area/area_references = list()

/obj/machinery/gravity_tether/multi_area/New()
	. = ..()
	for (var/area_typepath in src.area_typepaths)
		var/area/A = get_area_by_type(area_typepath)
		if (istype(A))
			src.area_references.Add(A)

/obj/machinery/gravity_tether/multi_area/activate()
	. = ..()
	for (var/area/A in src.area_references)
		A.has_gravity = TRUE

/obj/machinery/gravity_tether/multi_area/deactivate()
	. = ..()
	for (var/area/A in src.area_references)
		A.has_gravity = FALSE

#undef TETHER_EMAG_CHANGE_CHANCE
#undef TETHER_EMAG_CHANGE_COUNT
