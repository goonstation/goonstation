ABSTRACT_TYPE(/obj/machinery/gravity_tether)
/obj/machinery/gravity_tether
	name = "Gravity Tether"
	desc = "A rather delicate piece of machinery that normalizes gravity to Earth-like levels."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "magbeacon"
	density = TRUE
	anchored = ANCHORED_ALWAYS
	bound_width = 32
	bound_height = 32
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	var/active = TRUE

/obj/machinery/gravity_tether/attack_hand(mob/user)
	. = ..()
	src.toggle()

/obj/machinery/gravity_tether/proc/toggle()
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

/obj/machinery/gravity_tether/station/New()
	. = ..()
	src.desc += " This one appears to control gravity on the entire [station_or_ship()]."

/obj/machinery/gravity_tether/station/activate()
	. = ..()
	for(var/area_name in get_accessible_station_areas())
		station_areas[area_name].has_gravity = TRUE

/obj/machinery/gravity_tether/station/deactivate()
	. = ..()
	for(var/area_name in get_accessible_station_areas())
		station_areas[area_name].has_gravity = FALSE

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
