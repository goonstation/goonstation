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
	var/law_required = FALSE

	emag_act(var/mob/user)
		if(src.loudness_mod > 0)
			if (user)
				user.show_text("You swipe the card against [src], and you feel a mechanism within click into place.", "red")
			src.loudness_mod = -1
			maptext_size = 4

	proc/are_you_the_law(mob/M as mob, text)
		text = sanitize_talk(text)
		if (findtext(text, "iamthelaw"))
			//you must be holding/wearing the megaphone
			//this check makes it so that someone can't stun you, stand on top of you and say "I am the law" to kill you
			if (src in M.contents)
				if (M.job != "Head of Security")
					src.cant_self_remove = 1
					playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
					logTheThing(LOG_COMBAT, src, "Is not the law. Caused explosion with Voice of the Law.")

					SPAWN(2 SECONDS)
						src.blowthefuckup(15)
					return 0
				else
					return 1	//just remove all capitalization and non-letter characters
	proc/sanitize_talk(var/msg)
		//find all characters that are not letters and remove em
		var/regex/r = regex("\[^a-z\]+", "g")
		msg = lowertext(msg)
		msg = r.Replace(msg, "")
		return msg



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

/obj/item/megaphone/hos
	name = "voice of the law"
	desc = "Inform the crew of how you ARE the law. May contain explosives."
	icon_state = "megaphone_hos"
	item_state = "megaphone_hos"
	is_syndicate = TRUE
	maptext_size = 18
	maptext_color = "#8d1422"
	maptext_outline_color = "#250606"
	law_required = TRUE

	emag_act()
		. = ..()
		law_required = FALSE
