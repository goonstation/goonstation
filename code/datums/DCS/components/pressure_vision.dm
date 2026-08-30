TYPEINFO(/datum/component/pressure_vision)
	initialization_args = list(
		ARG_INFO("start_active", DATA_INPUT_BOOL, "Does it start immediately or after the first signal")
	)

/datum/component/pressure_vision
	//this is literally just a 32x32 white square, someone please tell me if there's a less dumb way to do this -TobleroneSwordfish
	var/icon/overlay_icon = 'icons/effects/effects.dmi'
	var/overlay_state = "atmos_overlay"
	var/list/image/atmos_overlays = null

/datum/component/pressure_vision/Initialize(start_active)
	if(!ismob(src.parent))
		return COMPONENT_INCOMPATIBLE

	src.atmos_overlays = list()
	src.toggle(src.parent, start_active)
	src.RegisterSignal(src.parent, COMSIG_PRESSURE_VISION, PROC_REF(toggle))
	. = ..()


/datum/component/pressure_vision/disposing()
	processing_items -= src
	. = ..()

/datum/component/pressure_vision/UnregisterFromParent()
	src.UnregisterSignal(src.parent, COMSIG_PRESSURE_VISION)
	processing_items -= src
	. = ..()

/datum/component/pressure_vision/proc/toggle(mob/parent, set_to)
	if(set_to)
		processing_items |= src
	else
		processing_items -= src

// Actual pressure vision process code:

/datum/component/pressure_vision/proc/process()
	var/mob/M = src.parent
	if (!istype(M) || !M.client)
		return

	src.clear_overlays(M)
	src.generate_overlays(M)

/datum/component/pressure_vision/proc/generate_overlays(mob/M)
	if (!M.client)
		return

	for (var/turf/simulated/T in view(M, M.client.view))
		if (!T.air)
			continue

		var/image/new_overlay = image(src.overlay_icon, T, src.overlay_state)
		var/relative_pressure = MIXTURE_PRESSURE(T.air)/ONE_ATMOSPHERE
		//make more orange if over one atmosphere
		new_overlay.color = rgb(91 * (max(1,relative_pressure)), 103, 231 / (max(1,relative_pressure)))
		new_overlay.alpha = 0

		animate(new_overlay, alpha=min(200, 200 * relative_pressure), time=2 DECI SECONDS)
		animate(alpha=0, time=2 SECONDS)

		src.atmos_overlays += new_overlay
		M.client.images += new_overlay

/datum/component/pressure_vision/proc/clear_overlays(mob/M)
	if (!M.client)
		return

	M.client.images -= src.atmos_overlays

	src.atmos_overlays = list()
