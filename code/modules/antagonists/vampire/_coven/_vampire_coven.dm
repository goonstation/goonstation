/**
 *	Currently just a global singleton, so only one coven per round is supported.
 */
/datum/vampire_coven
	var/list/datum/mind/members = null
	var/blood = 0
	var/total_blood = 0

/datum/vampire_coven/New()
	. = ..()
	src.members = list()

/datum/vampire_coven/proc/add_member(datum/mind/mind)
	if (!istype(mind))
		return

	src.members[mind] = TRUE

/datum/vampire_coven/proc/remove_member(datum/mind/mind)
	if (!istype(mind))
		return

	src.members -= mind

/datum/vampire_coven/proc/is_member(datum/mind/mind)
	if (!istype(mind))
		return

	return src.members[mind]





/*
 *	Event drain stuff.
 */
#define EVENT_STATE_PREFLOOD 0
#define EVENT_STATE_FLOOD 1
#define EVENT_STATE_POSTFLOOD 2

var/event_state = EVENT_STATE_PREFLOOD

/client/proc/cmd_set_event_state()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "0: Set Event State"
	set desc = "Set the current state of the Halloween event."
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/list/event_states = list(
		"0: Pre-Flood" = EVENT_STATE_PREFLOOD,
		"1: Flood & Lightsout" = EVENT_STATE_FLOOD,
		"2: Post-Flood" = EVENT_STATE_POSTFLOOD,
	)
	var/new_event_state = global.tgui_input_list(src, "Current State: [global.event_state]", "Set Event State", event_states)
	if (isnull(new_event_state))
		return

	global.event_state = event_states[new_event_state]
	global.message_admins("[src] has set the event state to [new_event_state].")

	if (global.event_state == EVENT_STATE_FLOOD)
		global.flood_drains()
		SPAWN (10 SECONDS)
			global.overload_lights()

	else
		for_by_tcl(drain, /obj/machinery/drainage)
			drain.flooding = FALSE

/proc/flood_drains()
	set waitfor = FALSE

	var/i = 0
	for_by_tcl(drain, /obj/machinery/drainage)
		if (drain.z != Z_LEVEL_STATION)
			continue

		var/area/A = get_area(drain)
		if (
			!istype(A, /area/station/crew_quarters/cafeteria) && \
			!istype(A, /area/station/crew_quarters/bar) && \
			!istype(A, /area/station/crew_quarters/kitchen)
		)
			continue

		if ((i++ % 5) == 0)
			sleep(1 SECOND)

		drain.flooding = TRUE
		drain.visible_message(SPAN_ALERT("[drain] starts overflowing with a blood-red liquid!"))

/proc/overload_lights()
	set waitfor = FALSE

	shuffle_list(global.stationLights)

	var/i = 0
	for (var/obj/machinery/light/light as anything in global.stationLights)
		if ((i++ % 5) == 0)
			sleep(0.1 SECOND)

		light.overload_act()


/obj/machinery/drainage
	var/flooding = FALSE

/obj/machinery/drainage/proc/event_process()
	if (src.clogged || src.welded)
		return FALSE

	switch (global.event_state)
		// Occasionally make gurgling sounds, but otherwise act normally.
		if (EVENT_STATE_PREFLOOD)
			if (!prob(5))
				return FALSE

			var/message = null
			var/gurgle_sound = null
			if (prob(90))
				message = "gurgles!"
				gurgle_sound = 'sound/misc/drain_glug.ogg'
			else
				message = "gurgles violently!"
				gurgle_sound = 'sound/ambience/spooky/Meatzone_Gurgle.ogg'
				DISPLAY_MAPTEXT(src, hearers(src, null), MAPTEXT_MOB_RECIPIENTS_WITH_OBSERVERS, /image/maptext/emote, "<i>gurgles</i>")

			src.visible_message(SPAN_SUBTLE("[src] [message]"))
			playsound(src.loc, gurgle_sound, 50, TRUE, pitch = 1 + (rand(-50, 50) / 160))

		// The the drain is marked as a flooding drain, spew blood and prevent it from draining liquid.
		if (EVENT_STATE_FLOOD)
			if (!src.flooding)
				return FALSE

			var/turf/T = get_turf(src)
			T.fluid_react_single("blood", 200)

			// Do not allow the drain to consume liquids while flooding.
			return TRUE

	// Allow the drain's `process` proc to continue normally.
	return FALSE
