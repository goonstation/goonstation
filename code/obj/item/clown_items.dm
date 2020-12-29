/*
CONTAINS:
BANANA PEEL
BIKE HORN
HARMONICA
VUVUZELA

*/

/obj/item/bananapeel
	name = "Banana Peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	icon_state = "banana-peel"
	item_state = "banana-peel"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 5
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	var/mob/living/carbon/human/last_touched

/obj/item/bananapeel/attack_hand(var/mob/user)
	last_touched = user
	..()

/obj/item/bananapeel/HasEntered(AM as mob|obj)
	if(istype(src.loc, /turf/space))
		return
	if (iscarbon(AM))
		var/mob/M =	AM
		if (M.slip(ignore_actual_delay = 1))
			boutput(M, "<span class='notice'>You slipped on the banana peel!</span>")
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.sims)
					H.sims.affectMotive("fun", -10)
					if (H == last_touched)
						H.sims.affectMotive("fun", -10)
			if (istype(last_touched) && (last_touched in viewers(src)) && last_touched != M)
				if (last_touched.sims)
					last_touched.sims.affectMotive("fun", 10)
			if(M.bioHolder.HasEffect("clumsy"))
				M.changeStatus("weakened", 5 SECONDS)
				JOB_XP(M, "Clown", 2)
			else
				if (prob(20))
					JOB_XP(last_touched, "Clown", 1)

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
		playsound(user.loc, "sound/items/can_open.ogg", 50, 0)

		SPAWN_DBG(0.5 SECONDS)
			// Wow your joke sucks
			if(prob(5))
				playsound(user.loc,"sound/misc/laughter/boo.ogg",50,0)
			else
				playsound(user.loc,"sound/misc/laughter/laughtrack[rand(1, 5)].ogg",50,0)

/obj/item/storage/box/box_o_laughs
	name = "Box o' Laughs"
	icon_state = "laughbox"
	desc = "A pack of canned laughter."
	spawn_contents = list(/obj/item/canned_laughter = 7)
