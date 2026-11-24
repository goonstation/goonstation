/*
CONTAINS:
BANANA PEEL
BIKE HORN
HARMONICA
VUVUZELA

*/

/obj/item/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	icon_state = "banana-peel"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "banana-peel"
	w_class = W_CLASS_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 5
	event_handler_flags = USE_FLUID_ENTER

/obj/item/bananapeel/New()
	. = ..()
	src.AddElement(/datum/element/slippery)


/obj/item/canned_laughter
	name = "Canned laughter"
	icon = 'icons/obj/foodNdrink/can.dmi'
	icon_state = "cola-5"
	desc = "All of the rewards of making a good joke with none of the effort! In a can!"
	var/opened = 0

	attack_self(mob/user as mob)
		..()
		if(src.opened)
			boutput(user,"The can has already been opened!")
			return
		opened = 1
		icon_state = "crushed-5"
		w_class = W_CLASS_TINY
		playsound(user.loc, 'sound/items/can_open.ogg', 50, 0)

		SPAWN(0.5 SECONDS)
			// Wow your joke sucks
			if(prob(5))
				playsound(user.loc, 'sound/misc/laughter/boo.ogg', 50,0)
			else
				playsound(user.loc,"sound/misc/laughter/laughtrack[rand(1, 4)].ogg",50,0)

	crushed
		name = "used up Canned laughter"
		opened = 1
		icon_state = "crushed-5"
		desc = "Someone had a good laugh - that is for certain!"

/obj/item/storage/box/box_o_laughs
	name = "Box o' Laughs"
	icon_state = "laughbox"
	desc = "A pack of canned laughter."
	spawn_contents = list(/obj/item/canned_laughter = 7)
