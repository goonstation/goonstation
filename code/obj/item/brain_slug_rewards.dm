//Rewards for killing a brain slug.

/obj/item/mutation_orb/mind_orb
	name = "essence of clairvoyance"
	desc = "A warm lump of flesh. Holding it brings you comfort"
	icon = 'icons/obj/items/mob_drops.dmi'
	icon_state = "mind_orb"

	envelop_message = "shimmering lights"
	leaving_message = "fading"

	New()
		. = ..()
		mutations_to_add = list(new /datum/mutation_orb_mutdata(id = "xray", stabilized = 1),
		new /datum/mutation_orb_mutdata(id = "telekinesis_drag", stabilized = 1))

/obj/item/slime_ball
	name = "slimy organ"
	desc = "A sticky, smelly organ dripping slime everywhere. You're pretty sure applying some of it to your shoes would allow you to stick to the ground easier."
	icon = 'icons/obj/items/mob_drops.dmi'
	icon_state = "slime_ball"
	var/color_to_set = "#6D7F53"

	afterattack(var/atom/target, mob/user, flag)
		if (istype(target, /obj/item/clothing/shoes))
			var/obj/item/clothing/shoes/the_shoes = target
			the_shoes.c_flags += NOSLIP
			the_shoes.color = src.color_to_set
			boutput(user, "<span class='notice'>You rub the slime ball on the sole of your shoes, making them sticky, slip resistant and absolutely repulsive.</span>")
			qdel(src)
		else
			..()
