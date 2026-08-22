/obj/machinery/nuclearbomb/event/large
	name = "KATABASIS"
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "nuclear_bomb_large" // Note the underscore: damage sprites check for "nuclearbomb".
	layer = EFFECTS_LAYER_BASE
	bound_width = 64
	bound_height = 32
	anyone_can_activate = TRUE
	target_override = /area/station
	target_override_name = "anywhere"

	var/static/total_bomb_number = 0
	var/bomb_number = null
	var/datum/action/bar/healthbar/healthbar = null

/obj/machinery/nuclearbomb/event/large/New()
	. = ..()

	if (isnum(src.bomb_number))
		src.total_bomb_number = max(src.total_bomb_number, src.bomb_number)
	else
		src.bomb_number = src.total_bomb_number++

	src.name = "KATABASIS " + global.add_zero(src.bomb_number, 2)

	src.maptext_x = 0
	src.maptext_y = 38

	src.healthbar = new /datum/action/bar/healthbar()
	src.healthbar.owner = src
	src.healthbar.onStart()
	src.healthbar.onUpdate()

/obj/machinery/nuclearbomb/event/large/disposing()
	QDEL_NULL(src.healthbar)
	. = ..()

/obj/machinery/nuclearbomb/event/large/update_health()
	. = ..()
	src.healthbar.onUpdate()


/datum/action/bar/healthbar
	bar_icon_state = "bar"
	border_icon_state = "border"
	color_active = "#9eee80"
	color_success = "#167935"
	color_failure = "#8d1422"
	bar_x_offset = 16
	bar_y_offset = 26

/datum/action/bar/healthbar/onUpdate()
	var/obj/O = src.owner
	if (!istype(O) || !src.bar || !src.border)
		return

	src.border.invisibility = INVIS_ALWAYS
	if (O._health == O._max_health)
		src.bar.invisibility = INVIS_ALWAYS
	else
		src.bar.invisibility = INVIS_NONE

	var/complete = O._health / O._max_health
	src.bar.color = "#00FF00"
	src.bar.transform = matrix(complete * 2, 1, MATRIX_SCALE)
	src.bar.pixel_x = src.bar_x_offset - ceil((60 - (60 * complete)) / 2)





/obj/landmark/braeriach_beacon
	name = LANDMARK_SYNDICATE_POD_RETURN_BEACON


/obj/item/shipcomponent/communications/syndicate/activate()
	var/atom/movable/screen/hud/pod/comms_use = ship.myhud.get_hudzone("main_panel").get_element("return_to_station").screen_obj
	comms_use.name = "Return to Braeriach"
	comms_use.desc = "Using this will return you to the Braeriach the next time you fly off the edge of the current level."
	. = ..()

/obj/item/shipcomponent/communications/syndicate/deactivate()
	var/atom/movable/screen/hud/pod/comms_use = ship.myhud.get_hudzone("main_panel").get_element("return_to_station").screen_obj
	comms_use.name = "Return To [capitalize(station_or_ship())]"
	comms_use.desc = "Using this will place you on the station Z-level the next time you fly off the edge of the current level."
	. = ..()

/obj/item/shipcomponent/communications/syndicate/go_home()
	if (!src.active)
		boutput(usr, "[src.ship.ship_message("Sensors inactive! Unable to calculate trajectory!")]")
		return TRUE

	var/turf/target = src.get_home_turf()
	if (!target)
		boutput(usr, "[src.ship.ship_message("Sensor error! Unable to calculate trajectory!")]")
		return TRUE

	var/obj/item/shipcomponent/engine/engine_part = src.ship.get_part(POD_PART_ENGINE)
	if (!engine_part)
		boutput(usr, "[src.ship.ship_message("Engines missing! Unable to calculate trajectory!")]")
		return TRUE

	if (!engine_part.active)
		boutput(usr, "[src.ship.ship_message("Engines inactive! Unable to calculate trajectory!")]")
		return TRUE

	if (!engine_part.ready)
		boutput(usr, "[src.ship.ship_message("Engine recharging! Unable to minimize trajectory error!")]")
		return TRUE

	if (istype(src.ship.movement_controller, /datum/movement_controller/pod))
		var/datum/movement_controller/pod/MCP = src.ship.movement_controller
		if (MCP.velocity_x != 0 || MCP.velocity_y != 0)
			boutput(usr, "[src.ship.ship_message("Ship must have ZERO relative velocity to calculate trajectory to destination!")]")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
			return TRUE

	else if (istype(src.ship.movement_controller, /datum/movement_controller/tank))
		var/datum/movement_controller/tank/MCT = src.ship.movement_controller
		if (MCT.input_x != 0 || MCT.input_y != 0)
			boutput(usr, "[src.ship.ship_message("Ship must have ZERO relative velocity (be stopped) to calculate trajectory destination!")]")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
			return TRUE

	engine_part.warp_autopilot = TRUE
	boutput(usr, "[src.ship.ship_message("Charging engines for escape velocity! Overriding manual control!")]")

	var/health_perc = src.ship.health_percentage
	src.ship.going_home = FALSE
	sleep(5 SECONDS)

	if (src.ship.health_percentage < (health_perc - 30))
		boutput(usr, "[src.ship.ship_message("Trajectory calculation failure! Ship characteristics changed from calculations!")]")
	else if(src.active)
		var/old_color = src.ship.color
		animate_teleport(src.ship)
		sleep(0.8 SECONDS)
		src.ship.set_loc(target)
		src.ship.color = old_color // revert color from teleport color-shift
	else
		boutput(usr, "[src.ship.ship_message("Trajectory calculation failure! Loss of systems!")]")

	engine_part.ready = FALSE
	engine_part.warp_autopilot = FALSE
	engine_part.ready()
	return TRUE

/obj/item/shipcomponent/communications/syndicate/get_home_turf()
	if (length(landmarks[LANDMARK_SYNDICATE_POD_RETURN_BEACON]))
		return pick(landmarks[LANDMARK_SYNDICATE_POD_RETURN_BEACON])





/obj/machinery/macrofab/syndicate
	name = "Pod Fabricator"
	desc = "A sophisticated machine that fabricates vehicles from a nearby reserve of supplies."
	createdObject = /obj/machinery/vehicle/miniputt/syndiputt
	itemName = "Syndicate pod"
	sound_volume = 15

/obj/machinery/macrofab/syndicate/attack_hand(mob/user)
	if (!istrainedsyndie(user))
		boutput(user, SPAN_ALERT("This machine's design makes no sense to you, you can't figure out how to use it!"))
		return

	. = ..()





// These layer under catwalks. Silly but pretty.
/obj/cable/braeriach
#ifndef IN_MAP_EDITOR
	plane = PLANE_FLOOR
	layer = CATWALK_LAYER - 0.001
#endif


/turf/simulated/floor/plating/with_grille
	icon = 'icons/turf/floors.dmi'
#ifdef IN_MAP_EDITOR
	icon_state = "plating_grille"
#else
	icon_state = "plating_jen"
#endif

/turf/simulated/floor/plating/with_grille/New()
	. = ..()

	if (!(locate(/obj/mesh/catwalk/base) in src))
		new /obj/mesh/catwalk/base(src)


/obj/mesh/catwalk/base
	name = "floor mesh"
	icon = 'icons/obj/catwalk_base.dmi'
	icon_state_prefix = "S"
	icon_state = "S-15"

/obj/mesh/catwalk/base/update_icon()
	if (src.ruined)
		return

	var/typeinfo/obj/mesh/typeinfo = src.get_typeinfo()
	var/connectdir = 0
	for (var/dir in global.cardinal)
		var/turf/T = get_step(src, dir)
		for (var/i in 1 to length(typeinfo.connects_to_obj))
			var/atom/movable/AM = locate(typeinfo.connects_to_obj[i]) in T
			if (AM?.anchored)
				connectdir |= dir
				break

	var/ordir = null
	for (var/i = 1 to 4)
		ordir = global.ordinal[i]
		if ((ordir & connectdir) != ordir)
			continue
		var/turf/OT = get_step(src, ordir)
		for (var/j in 1 to length(typeinfo.connects_to_obj))
			var/atom/movable/AM = locate(typeinfo.connects_to_obj[j]) in OT
			if (AM?.anchored)
				connectdir |= 8 << i
				break

	src.icon_state = "[src.icon_state_prefix]-[connectdir]"





//------------ Areas ------------//
/area/space/braeriach
	name = "space (Braeriach)"
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/braeriach
	teleport_blocked = AREA_TELEPORT_BLOCKED
	allowed_restricted_z = TRUE


ABSTRACT_TYPE(/area/braeriach)
/area/braeriach
	name = "Braeriach"
	icon_state = "red"
	occlude_foreground_parallax_layers = TRUE
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/braeriach
	minimaps_to_render_on = MAP_SYNDICATE
	station_map_colour = MAPC_SYNDICATE
	teleport_blocked = AREA_TELEPORT_BLOCKED
	do_not_irradiate = TRUE
	expandable = FALSE
	allowed_restricted_z = TRUE


ABSTRACT_TYPE(/area/braeriach/command)
/area/braeriach/command

/area/braeriach/command/bridge
	name = "Braeriach Bridge"
/area/braeriach/command/war_room
	name = "Braeriach War Room"
/area/braeriach/command/war_room/radio
	name = "Braeriach Radio Room"
/area/braeriach/command/foyer
	name = "Braeriach Bridge Foyer"


/area/braeriach/armament_depot
	name = "Braeriach Armament Depot"
/area/braeriach/armament_depot/vestibule
	name = "Braeriach Access Vestibule (Armament Depot)"


/area/braeriach/teleporter
	name = "Braeriach Teleporter"
/area/braeriach/teleporter/control
	name = "Braeriach Teleporter Control Room"


/area/braeriach/ai
	name = "Braeriach AI Core"
/area/braeriach/ai/vestibule
	name = "Braeriach Access Vestibule (AI Core)"
/area/braeriach/ai/upload
	name = "Braeriach AI Upload"


/area/braeriach/podbay
	name = "Braeriach Podbay"
/area/braeriach/podbay/armoury
	name = "Braeriach Podbay Armoury"
/area/braeriach/podbay/warehouse
	name = "Braeriach Podbay Warehouse"


/area/braeriach/medbay
	name = "Braeriach Medbay"
/area/braeriach/medbay/morgue
	name = "Braeriach Morgue"
/area/braeriach/medbay/pharmacy
	name = "Braeriach Pharmacy"
/area/braeriach/medbay/surgery
	name = "Braeriach Operating Theatre"


/area/braeriach/engineering
	name = "Braeriach Engineering Wing"
/area/braeriach/engineering/storage
	name = "Braeriach Engineering Storage"
/area/braeriach/engineering/gas_storage
	name = "Braeriach Engineering Gas Storage"
/area/braeriach/engineering/tether
	name = "Braeriach Gravity Tether"
/area/braeriach/engineering/power
	name = "Braeriach Power Control Room"


/area/braeriach/secure
	name = "Braeriach Secure Wing"
/area/braeriach/secure/armoury
	name = "Braeriach Armoury"
/area/braeriach/secure/firing_range
	name = "Braeriach Firing Range"
/area/braeriach/secure/equipment
	name = "Braeriach Equipment Storage"


/area/braeriach/crew
	name = "Braeriach Crew Quarters"
/area/braeriach/crew/jazz_lounge
	name = "Braeriach Jazz Lounge"
/area/braeriach/crew/bar
	name = "Braeriach Bar"
/area/braeriach/crew/kitchen
	name = "Braeriach Kitchen"
/area/braeriach/crew/freezer
	name = "Braeriach Kitchen Freezer"
/area/braeriach/crew/barracks
	name = "Braeriach Crew Barracks"
/area/braeriach/crew/bathroom
	name = "Braeriach Bathroom"
/area/braeriach/crew/janitor
	name = "Braeriach Janitor's Closet"


ABSTRACT_TYPE(/area/braeriach/maintenance)
/area/braeriach/maintenance

/area/braeriach/maintenance/disposals
	name = "Braeriach Disposals"
/area/braeriach/maintenance/central
	name = "Braeriach Central Maintenance"
/area/braeriach/maintenance/west
	name = "Braeriach West Maintenance"
/area/braeriach/maintenance/south_east
	name = "Braeriach South East Maintenance"
/area/braeriach/maintenance/north_east
	name = "Braeriach North East Maintenance"
/area/braeriach/maintenance/north
	name = "Braeriach North Maintenance"


ABSTRACT_TYPE(/area/braeriach/maintenance)
/area/braeriach/hallway

/area/braeriach/hallway/north
	name = "Braeriach North Primary Hallway"
/area/braeriach/hallway/south
	name = "Braeriach South Primary Hallway"
/area/braeriach/hallway/east
	name = "Braeriach East Primary Hallway"
