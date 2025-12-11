TYPEINFO(/obj/machinery/gravity_tether/current_area)
	mats = list("metal" = 30,
				"crystal_dense" = 10,
				"metal_superdense" = 10,
				"energy_extreme" = 5,
				)
/obj/machinery/gravity_tether/current_area
	name = "local-area gravity tether"
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "area_tether"
	bound_width = 32
	bound_height = 32
	// TODO: Power balancing, UX
	passive_wattage_per_g = 10 WATTS
	intensity = 0
	target_intensity = 0

/obj/machinery/gravity_tether/current_area/New()
	src.target_area_refs = list(get_area(src))
	. = ..()

/obj/machinery/gravity_tether/current_area/attempt_gravity_change(new_intensity)
	var/area/A = get_area(src)
	if (!A || !A.area_apc)
		return FALSE
	. = ..()

// if the gravity is 0 then let it be moved
/obj/machinery/gravity_tether/current_area/change_intensity(new_intensity)
	. = ..()
	if (.)
		return .
	var/area/A = get_area(src)
	for (var/mob/M in A)
		if (M.client)
			shake_camera(M, 5, 32, 0.2)
	if (src.intensity == 0)
		src.anchored = UNANCHORED
	else
		src.anchored = ANCHORED
