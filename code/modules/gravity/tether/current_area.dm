TYPEINFO(/obj/machinery/gravity_tether/current_area)
	mats = list("metal" = 30,
				"crystal_dense" = 10,
				"metal_superdense" = 10,
				"energy_extreme" = 5,
				)
/obj/machinery/gravity_tether/current_area
	name = "local-area gravity tether"
	// TODO: Power balancing
	passive_wattage_per_g = 10 WATTS
	gforce_intensity = 0
	target_intensity = 0
	anchored = UNANCHORED
	always_slow_pull = TRUE
	p_class = 10

/obj/machinery/gravity_tether/current_area/New()
	src.desc += " This one covers a small area."
	. = ..()
	src.light.attach(src, 0.5, 1)
	src.update_ma_status()
	src.UpdateIcon()

/obj/machinery/gravity_tether/current_area/attempt_gravity_change(new_gforce)
	var/area/A = get_area(src)
	if (!A || !A.area_apc)
		return FALSE
	// lockdown on attempting gravity change
	if (src.gforce_intensity == 0 && new_gforce > 0)
		src.activate(A)
	. = ..()
	// but if we fail to start the gravity, unlock
	if (src.processing_state == TETHER_PROCESSING_STABLE)
		src.deactivate(A)

/obj/machinery/gravity_tether/current_area/shake_affected()
	var/area/A = get_area(src)
	for (var/mob/M in A)
		if (M.client)
			shake_camera(M, 5, 32, 0.2)

/obj/machinery/gravity_tether/current_area/change_intensity(new_intensity)
	. = ..()
	if (.)
		return .
	var/area/A = get_area(src)
	if (src.gforce_intensity > 0)
		src.activate(A)
	else
		src.deactivate(A)

/obj/machinery/gravity_tether/current_area/proc/activate(area/A)
	src.anchored = ANCHORED_ALWAYS
	src.target_area_refs = list(A)

/obj/machinery/gravity_tether/current_area/proc/deactivate(area/A)
	src.target_area_refs = list()
