// Replaces a map computer screen with video and audio from a set

/// Is the map broadcast for this faction enabled
var/global/list/map_broadcast_enabled = list(
	FACTION_NANOTRASEN = FALSE,
	FACTION_SYNDICATE = FALSE,
)

/obj/hearing_connector
	name = "Hearing Connector"
	icon = 'icons/mob/screen1.dmi'
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED_ALWAYS
	var/id = "default"

/obj/hearing_connector/target
	icon_state = "down"

/obj/hearing_connector/target/New()
	. = ..()
	START_TRACKING

/obj/hearing_connector/target/disposing()
	STOP_TRACKING
	. = ..()

// TODO: Need to add to the HTR spawn ship (currently in secret?)
/obj/hearing_connector/target/nanotrasen
	id = FACTION_NANOTRASEN

/obj/hearing_connector/target/syndicate
	id = FACTION_SYNDICATE

/obj/hearing_connector/origin
	icon_state = "up"

/obj/hearing_connector/origin/New()
	. = ..()
	START_TRACKING

	if ((global.map_broadcast_enabled[src.id]))
		src.enable()

/obj/hearing_connector/origin/disposing()
	STOP_TRACKING
	. = ..()

/obj/hearing_connector/origin/proc/enable()
	var/turf/origin = get_turf(src)
	origin.listening_turfs ||= list()

	for_by_tcl(connector, /obj/hearing_connector/target)
		if (src == connector)
			continue
		if (connector.id != src.id)
			continue
		var/turf/target = get_turf(connector)
		origin.listening_turfs += target

/obj/hearing_connector/origin/proc/disable()
	var/turf/origin = get_turf(src)
	origin.listening_turfs ||= list()

	for_by_tcl(connector, /obj/hearing_connector/target)
		if (src == connector)
			continue
		if (connector.id != src.id)
			continue
		var/turf/target = get_turf(connector)
		origin.listening_turfs -= target

/obj/hearing_connector/origin/nanotrasen
	id = FACTION_NANOTRASEN
/obj/hearing_connector/origin/syndicate
	id = FACTION_SYNDICATE

/area/high_command
	icon_state = "green"
	var/id = null

/area/high_command/nanotrasen
	name = "Nanotrasen High Command"
/area/high_command/nanotrasen/office_set
	name = "Nanotrasen Commander's Office"
	icon_state = "blue"
	id = FACTION_NANOTRASEN

/area/high_command/syndicate
	name = "Syndicate High Command"
/area/high_command/syndicate/office_set
	name = "Syndicate Commander's Office"
	icon_state = "red"
	id = FACTION_SYNDICATE

/client/proc/toggle_carnigorm_briefing()
	set name = "Toggle Cairngorm Briefing Screen"
	set desc = "Change the minimap screen on the Carnigorm to show an office set instead of the minimap."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	ADMIN_ONLY

	var/state = tgui_alert(usr, "Cairngorm Briefing Screen:", "Confirmation", list("On", "Off"))
	var/toggle = FALSE
	if (state == "On")
		toggle = TRUE

	if (global.map_broadcast_enabled[FACTION_SYNDICATE] == toggle)
		return

	global.map_broadcast_enabled[FACTION_SYNDICATE] = toggle

	if (toggle)
		for_by_tcl(connector, /obj/hearing_connector/origin)
			if (connector.id == FACTION_SYNDICATE)
				connector.enable()
		for_by_tcl(map, /datum/minimap/area_map/broadcast)
			if (map.id == FACTION_SYNDICATE)
				map.enable_broadcast()
	else
		for_by_tcl(connector, /obj/hearing_connector/origin)
			if (connector.id == FACTION_SYNDICATE)
				connector.disable()
		for_by_tcl(map, /datum/minimap/area_map/broadcast)
			if (map.id == FACTION_SYNDICATE)
				map.disable_broadcast()

	message_admins(SPAN_INTERNAL("[key_name(src)] has toggled the Cairngorm Briefing Screen [state]."))
	logTheThing(LOG_ADMIN, src, "toggled the Cairngorm Briefing Screen [state].")

/client/proc/toggle_HTR_briefing()
	set name = "Toggle HTR Briefing Screen"
	set desc = "Change the minimap screen on the HTR Team ship to show an office set instead of the minimap."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	ADMIN_ONLY

	var/state = tgui_alert(usr, "HTR Briefing Screen:", "Confirmation", list("On", "Off"))
	var/toggle = FALSE
	if (state == "On")
		toggle = TRUE

	if (global.map_broadcast_enabled[FACTION_NANOTRASEN] == toggle)
		return

	global.map_broadcast_enabled[FACTION_NANOTRASEN] = toggle

	if (toggle)
		for_by_tcl(connector, /obj/hearing_connector/origin)
			if (connector.id == FACTION_NANOTRASEN)
				connector.enable()
		for_by_tcl(map, /datum/minimap/area_map/broadcast)
			if (map.id == FACTION_NANOTRASEN)
				map.enable_broadcast()

	else
		for_by_tcl(connector, /obj/hearing_connector/origin)
			if (connector.id == FACTION_NANOTRASEN)
				connector.disable()
		for_by_tcl(map, /datum/minimap/area_map/broadcast)
			if (map.id == FACTION_NANOTRASEN)
				map.disable_broadcast()

	message_admins(SPAN_INTERNAL("[key_name(src)] has toggled the HTR Briefing Screen [state]."))
	logTheThing(LOG_ADMIN, src, "toggled the HTR Briefing Screen [state].")
