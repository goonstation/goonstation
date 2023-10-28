/// fires created by chemical or magical sources
/// use /proc/chemfireflash or similar to create one, instead of creating a new chem_fire object
/obj/chem_fire
	mouse_opacity = 0
	anchored = ANCHORED_ALWAYS
	flags = UNCRUSHABLE
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	plane = PLANE_ABOVE_LIGHTING

	icon = 'icons/effects/fire.dmi'
	icon_state = CHEM_FIRE_RED

	blend_mode = BLEND_ADD

	// light source created by the fire
	var/datum/light/light
	/// volume of fire to expose to crossing atoms
	var/volume
	/// temperature of fire
	var/temperature

/obj/chem_fire/New(turf/T, volume = 125, temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST, duration = 3 SECONDS, color = CHEM_FIRE_RED)
	..()
	if (istype(T, /turf/space) || (locate(/obj/fire_foam) in T))
		qdel(src)
		return
	if (istype(T, /turf/simulated))
		var/turf/simulated/sim_turf = T
		if (!sim_turf.air || (sim_turf.air.oxygen < 0.5 MOLES && sim_turf.air.toxins < 0.5 MOLES))
			qdel(src)
			return
	if (temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST || volume <= 1)
		qdel(src)
		return
	var/area/A = get_area(T)
	if (A.sanctuary)
		return

	for (var/obj/chem_fire/existing_fire in T)
		if (existing_fire == src)
			continue
		src.temperature = max(src.temperature, existing_fire.temperature)
		qdel(existing_fire)
		break

	START_TRACKING

	src.volume = volume
	src.icon_state = color

	src.light = new /datum/light/point
	src.light.set_brightness(0.1, queued_run = TRUE)
	src.light.attach(src)
	src.light.enable(queued_run = TRUE)

	src.process_burn()
	src.changeStatus("chem_fire_burning", duration)

/obj/chem_fire/disposing()
	STOP_TRACKING
	src.light?.disable(queued_run = TRUE)
	qdel(src.light)
	..()

/obj/chem_fire/Crossed(atom/movable/AM)
	..()
	AM.temperature_expose(null, src.temperature, src.volume)
	if (isliving(AM))
		var/mob/living/L = AM
		L.update_burning(10)

/obj/chem_fire/ex_act()
	return

/obj/chem_fire/blob_act()
	return

// chem fire process - turf effects, burns things touching it
/obj/chem_fire/proc/process_burn()
	var/turf/T = get_turf(src)

	if (istype(T, /turf/simulated))
		var/turf/simulated/sim_turf = T

		// increase fire temp to air temp if its greater
		var/datum/gas_mixture/loc_air = sim_turf.air
		if (loc_air.temperature > src.temperature)
			src.temperature = loc_air.temperature
		else
			src.temperature = temperature
			loc_air.temperature = src.temperature

		sim_turf.hotspot_expose(src.temperature, src.volume, TRUE)

	T.burn_tile()

	for (var/atom/A as anything in T)
		A.temperature_expose(null, src.temperature, src.volume)
		if (istype(A, /mob/living))
			var/mob/living/L = A
			L.update_burning(10)
