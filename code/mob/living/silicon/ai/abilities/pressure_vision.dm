/datum/targetable/ai/program/pressure_vision
	name = "Pressure Visualizer"
	desc = "Toggle seeing air pressure visualized when viewing station flooring."
	icon_state = "vis_atmos"

	var/on = FALSE
	var/datum/component/frame_component_ref = null
	var/datum/component/eye_component_ref = null

	onAttach(datum/abilityHolder/H)
		. = ..()
		var/mob/living/silicon/ai/AI = src.holder.owner
		frame_component_ref = AI.AddComponent(/datum/component/pressure_vision, src.on)
		if(istype(AI) && AI.eyecam)
			eye_component_ref = AI.eyecam.AddComponent(/datum/component/pressure_vision, src.on)

	cast(atom/target)
		. = ..()
		if (.)
			return
		var/mob/living/silicon/ai/AI = src.holder.owner
		AI.playsound_local(AI, 'sound/machines/tone_beep.ogg', 40, TRUE)
		src.on = !src.on

		SEND_SIGNAL(AI, COMSIG_PRESSURE_VISION, src.on)
		if(istype(AI) && AI.eyecam)
			SEND_SIGNAL(AI.eyecam, COMSIG_PRESSURE_VISION, src.on)

	disposing()
		. = ..()
		src.frame_component_ref?.RemoveComponent()
		src.eye_component_ref?.RemoveComponent()
