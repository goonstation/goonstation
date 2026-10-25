/datum/component/manual_blinking
	var/blink_timer = 0
	var/warning_stage = 0
	var/blink_state = 0

TYPEINFO(/datum/component/manual_blinking)
	initialization_args = list()

/datum/component/manual_blinking/Initialize()
	. = ..()
	if (!ishuman(src.parent))
		return COMPONENT_INCOMPATIBLE

	boutput(src.parent, SPAN_ALERT("You must now blink manually using the *closeeyes and *openeyes emotes!"))
	src.RegisterSignal(src.parent, COMSIG_LIVING_LIFE_TICK, PROC_REF(process))
	src.RegisterSignal(src.parent, COMSIG_MOB_EMOTE, PROC_REF(on_emote))

/datum/component/manual_blinking/UnregisterFromParent()
	boutput(src.parent, SPAN_ALERT("You no longer need to blink manually!"))
	src.UnregisterSignal(src.parent, COMSIG_LIVING_LIFE_TICK)
	src.UnregisterSignal(src.parent, COMSIG_MOB_EMOTE)
	. = ..()

/datum/component/manual_blinking/proc/process(_, mult)
	var/mob/living/carbon/human/H = src.parent
	if (H.find_ailment_by_type(/datum/ailment/disability/blind))
		src.blink_timer = 0
		return

	if (src.blink_state)
		H.take_eye_damage(clamp(1 - H.get_eye_damage(TRUE), 0, 1), TRUE)
		return

	src.blink_timer += mult

	switch (src.blink_timer)
		if (0 to 20)
			src.warning_stage = 0

		if (20 to 30)
			if (src.warning_stage < 1)
				boutput(H, SPAN_ALERT("Your eyes feel slightly uncomfortable!"))
				src.warning_stage = 1

		if (30 to 40)
			if (src.warning_stage < 2)
				boutput(H, SPAN_ALERT("Your eyes feel quite dry!"))
				src.warning_stage = 2

		if (40 to 60)
			H.change_eye_blurry(3, 3)

			if (src.warning_stage < 3)
				boutput(H, SPAN_ALERT("Your eyes feel very dry and uncomfortable, it's getting difficult to see!"))
				src.warning_stage = 3

		if (60 to 100)
			H.take_eye_damage(clamp(3 - H.get_eye_damage(TRUE), 0, 3), TRUE)

			if (src.warning_stage < 4)
				boutput(H, SPAN_ALERT("Your eyes are so dry that you can't see a thing!"))
				src.warning_stage = 4

		if (100 to INFINITY)
			H.contract_disease(/datum/ailment/disability/blind, null, null, TRUE)

			if (src.warning_stage < 5)
				boutput(H, SPAN_ALERT("You feel a horrible pain in your eyes. That can't be good."))
				src.warning_stage = 5

/datum/component/manual_blinking/proc/on_emote(_, emote)
	var/mob/living/carbon/human/H = src.parent

	switch (emote)
		if ("closeeyes")
			if (src.blink_state)
				boutput(H, SPAN_ALERT("You just closed your eyes, try opening them now dumbo!"))
				return

			src.blink_timer = 0
			src.blink_state = 1
			boutput(H, SPAN_NOTICE("You close your eyes."))

		if ("openeyes")
			if (!src.blink_state)
				boutput(H, SPAN_ALERT("Your eyes are already open, try closing them next moron!"))
				return

			src.blink_state = 0
			boutput(H, SPAN_NOTICE("You open your eyes."))


var/global/manual_blinking = FALSE

/proc/toggle_manual_blinking(toggle)
	if (global.manual_blinking == toggle)
		return

	global.manual_blinking = toggle
	if (global.manual_blinking)
		for (var/client/C as anything in global.clients)
			if (!ishuman(C?.mob))
				continue

			C.mob.AddComponent(/datum/component/manual_blinking)

	else
		for_by_tcl(H, /mob/living/carbon/human)
			H.RemoveComponentsOfType(/datum/component/manual_blinking)
