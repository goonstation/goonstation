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
	var/makes_you_quieter = FALSE
	var/maptext_size = 14 //how big in px it makes your text. lower numbers can make your text smaller
	var/maptext_color = "#b0e8b3"
	var/maptext_outline_color = "#043606"

	emag_act(var/mob/user)
		if(!makes_you_quieter)
			if (user)
				user.show_text("You swipe the card against [src], and you feel a mechanism within click into place.", "red")
			makes_you_quieter = TRUE
			maptext_size = 4
