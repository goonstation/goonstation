TYPEINFO(/obj/item/device/speech_pro)
	mats = 14
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_DEVICE)

/obj/item/device/speech_pro
	name = "Speech Pro"
	desc = "This device can output a variety of phrases for easy communication."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "speech_pro"
	item_state = "speech_pro"
	w_class = W_CLASS_SMALL
	rand_pos = 0
	c_flags = ONBELT
	contextLayout = new /datum/contextLayout/experimentalcircle
	speech_verb_say = list("squawks", "beeps", "boops", "says", "screeches")

	///Custom contextActions list so we can handle opening them ourselves
	var/list/datum/contextAction/contexts = list()

	/// The phrases that this device has available to it
	var/list/phrases = list(
		SPEECH_PRO_SAY_HELLO, SPEECH_PRO_SAY_BYE, SPEECH_PRO_SAY_HELP, SPEECH_PRO_SAY_WHAT, SPEECH_PRO_SAY_THX, SPEECH_PRO_SAY_SRY, \
		SPEECH_PRO_SAY_GJ, SPEECH_PRO_SAY_WAIT, SPEECH_PRO_SAY_YES, SPEECH_PRO_SAY_NO, SPEECH_PRO_SAY_FOLLOW, SPEECH_PRO_SAY_SP
	)

	New()
		..()
		src.AddComponent(/datum/component/log_item_pickup, first_time_only=FALSE, message_admins_too=FALSE)
		for(var/actionType in childrentypesof(/datum/contextAction/speech_pro)) //see context_actions.dm for those
			var/datum/contextAction/speech_pro/action = new actionType()
			if (action.phrase in src.phrases)
				src.contexts += action

	attack_self(mob/user as mob)
		user.showContextActions(src.contexts, src, src.contextLayout)
