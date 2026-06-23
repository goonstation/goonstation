//Place for the new chaplain books to live since they function differently from the bible
//June 23 2026 update, other books no longer work differently. Is this file obsolete? probably

/obj/item/scripture
	name = "blank scripture"
	icon = 'icons/obj/writing.dmi'
	icon_state = "blankhb"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "blankhb"
	desc = "An interpretive holy scripture touting… just about whatever you want, really."
	var/item_state_base = "blankhb"
	var/is_open = FALSE

	attack_self(mob/user)
		if (user.find_in_hand(src))
			if (!src.is_open)
				src.open(user)
			else
				src.close(user)
			user.update_inhands()

	proc/open (mob/user as mob)
		src.is_open = TRUE
		icon_state = "[icon_state]open"
		item_state = "[item_state]open"

	proc/close (mob/user as mob)
		src.is_open = FALSE
		icon_state = "[src.item_state_base]"
		item_state = "[src.item_state_base]"
