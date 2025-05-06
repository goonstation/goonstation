/obj/item/megaphone
	name = "megaphone"
	desc = "The captain's megaphone, fancily decorated to match their typical fashion sense. Useful for barking demands at staff assistants or getting your point across."
	icon = 'icons/obj/objects.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "megaphone"
	item_state = "megaphone"
	force = 0
	throwforce = 0
	w_class = W_CLASS_SMALL
	throw_speed = 4
	throw_range = 10
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	var/maptext_size = 12 //how big in px it makes your text. lower numbers can make your text smaller
	var/maptext_color = "#b0e8b3"
	var/maptext_outline_color = "#043606"
	/// Amount this modifies your speech loudness by, ranging from -1 to 2
	var/loudness_mod = 1

	pickup(mob/M)
		. = ..()

		M.ensure_speech_tree().AddSpeechModifier(SPEECH_MODIFIER_MEGAPHONE)

	dropped(mob/M)
		M.ensure_speech_tree().RemoveSpeechModifier(SPEECH_MODIFIER_MEGAPHONE)

		. = ..()

	emag_act(var/mob/user)
		if(src.loudness_mod > 0)
			if (user)
				user.show_text("You swipe the card against [src], and you feel a mechanism within click into place.", "red")
			src.loudness_mod = -1
			maptext_size = 4

/obj/item/megaphone/syndicate
	name = "black-market megaphone"
	desc = "The ultimate tool in authority assertion. Highly illegal, highly effective."
	icon_state = "megaphone_syndie"
	item_state = "megaphone_syndie"
	is_syndicate = TRUE
	maptext_size = 24
	maptext_color = "#510F22"
	maptext_outline_color = "#130C1F"
	loudness_mod = 2
