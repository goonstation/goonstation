TYPEINFO(/datum/component/wearertargeting/pressure_vision)
	initialization_args = list(
		ARG_INFO("valid_slots", DATA_INPUT_LIST_BUILD, "List of wear slots that the component should function in \[1-19\]"),
	)

/datum/component/wearertargeting/pressure_vision
	var/list/image/atmos_overlays = list()
	//this is literally just a 32x32 white square, someone please tell me if there's a less dumb way to do this
	var/icon/overlay_icon = 'icons/effects/effects.dmi'
	var/overlay_state = "atmos_overlay"
	var/list/image/atmos_overlays = list()

	var/active


	Initialize(_valid_slots)
		. = ..()
		if(!isitem(parent))
			return COMPONENT_INCOMPATIBLE

		if((SLOT_L_HAND in valid_slots) || (SLOT_R_HAND in valid_slots))
			parent:c_flags |= EQUIPPED_WHILE_HELD

/datum/component/wearertargeting/pressure_vision/proc/on_equip(datum/source, mob/equipper, slot)
	var/obj/item/I = parent
	//ability add
	. = ..()

/datum/component/wearertargeting/pressure_vision/proc/on_unequip(datum/source, mob/user)
	var/obj/item/I = parent
	//ability remove
	if(src.active)
		src.turn_off()
	. = ..()

/datum/component/wearertargeting/pressure_vision/disposing()
	processing_items -= src

/datum/component/wearertargeting/energy_shield/proc/turn_off()
	processing_items -= src
	src.activate = TRUE
	toggler.playsound_local(src, 'sound/machines/tone_beep.ogg', 40, TRUE)

/datum/component/wearertargeting/energy_shield/proc/turn_on()
	processing_items |= src
	src.activate = FALSE
	toggler.playsound_local(src, 'sound/machines/tone_beep.ogg', 40, TRUE)

/datum/component/wearertargeting/energy_shield/proc/toggle()
	if(active)
		src.turn_off()
	else
		src.turn_on()

// Actual pressure vision code:

/datum/component/wearertargeting/pressure_vision/proc/process()
	var/mob/M = src.current_user
	if (!istype(M) || !M.client)
		return
	src.clear_overlays(M)
	src.generate_overlays(M)

/datum/component/wearertargeting/pressure_vision/proc/generate_overlays(mob/M)
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

/datum/component/wearertargeting/pressure_vision/proc/clear_overlays(mob/M)
	if (!M.client)
		return
	for (var/image/image as anything in src.atmos_overlays)
		M.client.images -= image
	src.atmos_overlays = list()
