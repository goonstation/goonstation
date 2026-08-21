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
