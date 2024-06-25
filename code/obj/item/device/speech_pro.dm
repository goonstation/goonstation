TYPEINFO(/obj/item/device/speech_pro)
	mats = 14

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

	proc/speak(var/string, var/mob/user)
		string = trimtext(sanitize(html_encode(string)))
		var/maptext = null
		var/maptext_loc = null //Location used for center of all_hearers scan "Probably where you want your text attached to."

		var/list/atom/movable/loc_chain = obj_loc_chain(src)
		maptext_loc = loc_chain[length(loc_chain)] // location of stop most container or possibly a mob.
		maptext = make_chat_maptext(maptext_loc, "[string]", "color: #FFBF00;", alpha = 255)

		for(var/mob/O in all_hearers(7, maptext_loc))
			O.show_message("<span class='radio' style='color: #FFBF00;'>[SPAN_NAME("[src]")]<b> [bicon(src)] [pick("squawks",  \
			"beeps", "boops", "says", "screeches")], </b> [SPAN_MESSAGE("\"[string]\"")]</span>",1, //Places text in the radio
				assoc_maptext = maptext) //Places text in world

		logTheThing(LOG_DEBUG, src, "[user] said [string] using [src].")
