/datum/component/manual_breathing
	var/breath_timer = 0
	var/warning_stage = 0
	var/breath_state = 0

TYPEINFO(/datum/component/manual_breathing)
	initialization_args = list()

/datum/component/manual_breathing/Initialize()
	. = ..()
	if (!ishuman(src.parent))
		return COMPONENT_INCOMPATIBLE

	boutput(src.parent, SPAN_ALERT("You must now breathe manually using the *inhale and *exhale emotes!"))
	src.RegisterSignal(src.parent, COMSIG_LIVING_LIFE_TICK, PROC_REF(process))
	src.RegisterSignal(src.parent, COMSIG_MOB_EMOTE, PROC_REF(on_emote))

/datum/component/manual_breathing/UnregisterFromParent()
	boutput(src.parent, SPAN_ALERT("You no longer need to breathe manually!"))
	src.UnregisterSignal(src.parent, COMSIG_LIVING_LIFE_TICK)
	src.UnregisterSignal(src.parent, COMSIG_MOB_EMOTE)
	. = ..()

/datum/component/manual_breathing/proc/process(_, mult)
	var/mob/living/carbon/human/H = src.parent
	var/datum/organ_status/lung/status_updates = new()

	src.breath_timer += mult
	if (src.breath_timer > 15)
		H.losebreath += (0.7 * mult)

	switch (src.breath_timer)
		if (0 to 15)
			src.warning_stage = 0

		if (34 to 51)
			if (prob(5))
				H.emote("gasp")

			if (src.warning_stage < 1)
				boutput(H, SPAN_ALERT("You need to breathe!"))
				src.warning_stage = 1

		if (51 to 61)
			status_updates.show_oxy_indicator = TRUE
			H.take_oxygen_deprivation(src.breath_timer / 12)

			if (src.warning_stage < 2)
				boutput(H, SPAN_ALERT("Your lungs start to hurt. You really need to breathe!"))
				src.warning_stage = 2

		if (61 to INFINITY)
			status_updates.show_oxy_indicator = TRUE
			H.take_oxygen_deprivation(src.breath_timer / 6)

			if (src.warning_stage < 3)
				boutput(H, SPAN_ALERT("Your lungs are burning and the need to take a breath is almost unbearable!"))
				src.warning_stage = 3

	H.hud.update_breathing_indicators(status_updates)

/datum/component/manual_breathing/proc/on_emote(_, emote)
	var/mob/living/carbon/human/H = src.parent

	switch (emote)
		if ("inhale")
			if (src.breath_state)
				boutput(H, SPAN_ALERT("You just breathed in, try breathing out next dummy!"))
				return

			src.breath_timer = 0
			src.breath_state = 1
			boutput(H, SPAN_NOTICE("You breathe in."))

		if ("exhale")
			if (!src.breath_state)
				boutput(H, SPAN_ALERT("You just breathed out, try breathing in next silly!"))
				return

			src.breath_state = 0
			boutput(H, SPAN_NOTICE("You breathe out."))


var/global/manual_breathing = FALSE

/proc/toggle_manual_breathing(toggle)
	if (global.manual_breathing == toggle)
		return

	global.manual_breathing = toggle
	if (global.manual_breathing)
		for (var/client/C as anything in global.clients)
			if (!ishuman(C?.mob))
				continue

			C.mob.AddComponent(/datum/component/manual_breathing)

	else
		for (var/client/C as anything in global.clients)
			if (!ishuman(C?.mob))
				continue

			C.mob.RemoveComponentsOfType(/datum/component/manual_breathing)
