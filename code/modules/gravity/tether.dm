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
	req_access = list(access_engineering_chief)
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
	for(var/area_name in get_accessible_station_areas())
		station_areas[area_name].has_gravity = TRUE

/obj/machinery/gravity_tether/proc/deactivate()
	src.active = FALSE
	src.icon_state = "magbeacon_off"
	for(var/area_name in get_accessible_station_areas())
		station_areas[area_name].has_gravity = FALSE

