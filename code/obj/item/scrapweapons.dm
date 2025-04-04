/* Scrap weapons
Cobbled together pieces of junk that make barely passable weapons.
Ideally they're weaker than some of the other common station weapons such as fire extinguishers or decon devices but still viable as weapons.
Meant to be a weapon you make if you can't find anything else.
*/


/*Abstract Types for Scrap Weapons */
ABSTRACT_TYPE(/obj/item/scrapweapons)
ABSTRACT_TYPE(/obj/item/scrapweapons/parts)
ABSTRACT_TYPE(/obj/item/scrapweapons/weapons)

/* Base object */
/obj/item/scrapweapons
	name = "youshouldntseeme basescrapweapon"
	icon = 'icons/obj/items/scrapweapons.dmi' //codersprites. improve if you want or feel the need
	inhand_image_icon = 'icons/mob/inhand/hand_scrapweapons.dmi'
	flags = TABLEPASS | NOSHIELD | USEDELAY
	object_flags = NO_GHOSTCRITTER // blanket ban on all scrapweapon items for ghost critters
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	is_syndicate = FALSE

/* Scrap weapon parts/in construction states */
/obj/item/scrapweapons/parts
	name = "youshouldntseethis scrapweaponbase"
	hit_type = DAMAGE_BLUNT
	w_class = W_CLASS_SMALL
	force = 1
	throwforce = 1
	attack_verbs = "whacks"

/obj/item/scrapweapons/parts/handle // base of all/most scrap weapons just as an easy starting point
	name = "scrap handle"
	desc = "A handle for a yet unmade weapon. Try attaching something to it."
	icon_state = "handle"
	material_amt = 0.1
	HELP_MESSAGE_OVERRIDE("You may attach the following items while holding a <b>lit welding tool</b> in your offhand to this handle to create a weapon:<br> A <b>scrap blade, shaft, or pole</b> which can be made with some metal sheets to make a machete, club, or spear, respectively. <br> Or a shard of <b>glass, plasmaglass, or scrap metal</b> to create a dagger")

	attackby(obj/item/W, mob/user)
		. = ..()
		var/successful	//Whether we successfully built something or not
		for	(var/obj/item/E in user.equipped_list())
			if (isweldingtool(E) && E:try_weld(user,0,0,0,0))
				if (istype(W, /obj/item/scrapweapons/parts/blade))
					qdel(W)
					qdel(src)
					user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/machete)
					boutput(user, SPAN_NOTICE("You fuse the handle and blade into a scrap machete."))
					successful = TRUE

				if (istype(W, /obj/item/scrapweapons/parts/shaft))
					qdel(W)
					qdel(src)
					user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/club)
					boutput(user, SPAN_NOTICE("You fuse the handle and shaft into a scrap club."))
					successful = TRUE


				if (istype(W, /obj/item/scrapweapons/parts/pole))
					qdel(W)
					qdel(src)
					user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/spear)
					boutput(user, SPAN_NOTICE("You fuse the handle and pole into a blunt scrap spear."))
					successful = TRUE


				if (istype(W, /obj/item/raw_material/scrap_metal))
					W.change_stack_amount(-1)
					qdel(src)
					user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/dagger)
					boutput(user, SPAN_NOTICE("You fuse the handle and scrap metal into a scrap dagger."))
					successful = TRUE

				else if (istype(W, /obj/item/raw_material/shard))
					if (istype(W.material, /datum/material/crystal/glass))
						W.change_stack_amount(-1)
						qdel(src)
						user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/dagger/glass)
						boutput(user, SPAN_NOTICE("You fuse the handle and glass shard into a scrap dagger."))
						successful = TRUE

					else if (istype(W.material, /datum/material/crystal/plasmaglass))
						W.change_stack_amount(-1)
						qdel(src)
						user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/dagger/plasmaglass)
						boutput(user, SPAN_NOTICE("You fuse the handle and plasmaglass shard into a scrap dagger."))
						successful = TRUE
				if (successful == TRUE)
					E:try_weld(user,2,-1,1,1)

/obj/item/scrapweapons/parts/blade
	name = "scrap blade"
	desc = "A flat and sharp piece of metal. Might work as a weapon in a pinch but you should try attaching it to something."
	icon_state = "blade"
	material_amt = 0.3
	HELP_MESSAGE_OVERRIDE("Attach this to a <b>scrap handle</b> while holding a <b>lit welding tool</b> in your <b>offhand</b> to create a <b>scrap machete</b>.")
	force = 5 // it's still a blade, just not a very good one yet
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'

/obj/item/scrapweapons/parts/shaft // im 12 years old and saying shaft makes me giggle
	name = "metal shaft"
	desc = "A long and round piece of metal. Try attaching it to something."
	icon_state = "shaft"
	material_amt = 0.2
	HELP_MESSAGE_OVERRIDE("Attach this to a <b>scrap handle</b> while holding a <b>lit welding tool</b> in your <b>offhand</b> to create a <b>scrap club</b>. <br> Or attach this to another <b>metal shaft</b> while holding a <b>lit welding tool</b> in your <b>offhand</b> to create a <b>metal pole</b>.")
	force = 4

	attackby(obj/item/W, mob/user)
		. = ..()
		for	(var/obj/item/E in user.equipped_list())
			if (isweldingtool(E) && E:try_weld(user,2,-1,1,1))
				if (istype(W, /obj/item/scrapweapons/parts/shaft))
					qdel(W)
					qdel(src)
					user.put_in_hand_or_drop(new/obj/item/scrapweapons/parts/pole)
					boutput(user, SPAN_NOTICE("You fuse the two shafts together into a <b>metal pole</b>."))

/obj/item/scrapweapons/parts/pole
	name = "metal pole"
	desc = "Two metal shafts attached together. Try attaching it to something."
	icon_state = "pole"
	HELP_MESSAGE_OVERRIDE("Attach this to a <b>scrap handle</b> while holding a <b>lit welding tool</b> in your <b>offhand</b> to create a <b>scrap spear</b>.")
	force = 5

/* Scrap weapons */
/obj/item/scrapweapons/weapons
	name = "youshouldntseemee scrapweapon"
	force = 5

	New()
		..()
		src.setItemSpecial(/datum/item_special/simple)

/obj/item/scrapweapons/weapons/spear
	name = "scrap spear"
	desc = "A long rod without anything on the end. Still effective as a blunt instrument, but maybe you should attach something to the end."
	HELP_MESSAGE_OVERRIDE("To create a pointed spear you should first attach some <b>wires</b> to the spear, then attach a piece of <b>scrap metal, glass, or plasmaglass</b> as the tip.")
	icon_state = "spear"
	item_state = "spear"
	w_class = W_CLASS_NORMAL
	hit_type = DAMAGE_BLUNT
	force = 6
	throwforce = 10
	custom_suicide = 1
	attack_verbs = "impales"
	hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
	custom_suicide = 1
	var/wireadded = FALSE

	New()
		..()
		src.setItemSpecial(/datum/item_special/rangestab)

	attackby(obj/item/W, mob/user)
		if (!src.wireadded)
			if (istype(W, /obj/item/cable_coil))
				if (W.amount >= 2)
					W.amount -= 2
					src.wireadded = TRUE
					boutput(user, SPAN_NOTICE("You attach the wire to the spear, now you just need a tip."))
					src.help_message = "Now attach a piece of <b>scrap metal, glass, or plasmaglass</b> to complete the spear."
					src.icon_state = "spear-wire"
					src.item_state = "spear-wire"
			else
				boutput(user, "<span class='alert>You need to attach some wires before you stick anything on the spear!</span>")
				. = ..()
		else if (istype(W, /obj/item/raw_material/scrap_metal))
			W.change_stack_amount(-1)
			qdel(src)
			user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/spear/scrapmetal)
			boutput(user, SPAN_NOTICE("You combine the blunt spear with the piece of scrap metal to add a sharp point."))

		else if (istype(W, /obj/item/raw_material/shard))
			if (istype(W.material, /datum/material/crystal/glass))
				W.change_stack_amount(-1)
				qdel(src)
				user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/spear/glass)
				boutput(user, SPAN_NOTICE("You combine the blunt spear with the shard of glass to add a sharp point."))

			else if (istype(W.material, /datum/material/crystal/plasmaglass))
				W.change_stack_amount(-1)
				qdel(src)
				user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/spear/plasmaglass)
				boutput(user, SPAN_NOTICE("You combine the blunt spear with the shard of scrap metal to add a sharp point."))

			else
				boutput(user, SPAN_ALERT("That just doesn't fit on the spear! Try glass or plasmaglass or scrap metal!"))
		else
			. = ..()



	scrapmetal
		desc = "A sharp pointy bit of metal strapped to a metal rod. Devastatingly simple."
		icon_state = "spear-scrapmetal"
		item_state = "spear-scrapmetal"
		force = 8
		hit_type = DAMAGE_STAB
		hitsound = 'sound/impact_sounds/Flesh_Stab_3.ogg'
		HELP_MESSAGE_OVERRIDE(null)

	glass
		desc = "A sharp pointy bit of glass strapped to a metal rod. Devastatingly simple."
		icon_state = "spear-glass"
		item_state = "spear-glass"
		force = 8
		hit_type = DAMAGE_STAB
		hitsound = 'sound/impact_sounds/Flesh_Stab_3.ogg'
		HELP_MESSAGE_OVERRIDE(null)

	plasmaglass
		desc = "A sharp pointy bit of plasmaglass strapped to a metal rod. Devastatingly simple."
		icon_state = "spear-pglass"
		item_state = "spear-pglass"
		force = 9 // plasmaglass is just a bit more damage dealing for scrap weapons
		hit_type = DAMAGE_STAB
		hitsound = 'sound/impact_sounds/Flesh_Stab_3.ogg'
		HELP_MESSAGE_OVERRIDE(null)

/obj/item/scrapweapons/weapons/spear/suicide(var/mob/living/carbon/human/user as mob)
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	else
		user.visible_message(SPAN_ALERT("<b>[user] impales [himself_or_herself(user)] with the [src], straight through the heart! </b>"))
		user.organHolder.drop_and_throw_organ("heart", dist = 5, speed = 1, showtext = 1)
		playsound(src.loc, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 50, 1)
		user.TakeDamage("chest", 100, 0)
		SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
		return 1

/obj/item/scrapweapons/weapons/machete
	name = "scrap machete"
	desc = "A few pieces of metal scraps cobbled together in the form of a machete. Looks deadly, to both the victim and the user..."
	icon_state = "machete"
	item_state = "machete"
	w_class = W_CLASS_NORMAL
	hit_type = DAMAGE_CUT
	tool_flags = TOOL_CUTTING | TOOL_CHOPPING
	force = 9
	attack_verbs = "hacks"
	hitsound = 'sound/impact_sounds/Flesh_Stab_3.ogg'
	custom_suicide = 1

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)

/obj/item/scrapweapons/weapons/machete/suicide(var/mob/living/carbon/human/user as mob)
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	else
		var/organtokill = pick("liver", "spleen", "appendix", "stomach", "intestines")
		user.visible_message(SPAN_ALERT("<b>[user] stabs the [src] into [his_or_her(user)] own chest, disemboweling [himself_or_herself(user)] and ripping out [his_or_her(user)] [organtokill]! [pick("Brutal", "Holy fucking SHIT", "Why would [he_or_she(user)] do that?")]!</b>"))
		user.organHolder.drop_and_throw_organ(organtokill, dist = 5, speed = 1, showtext = 1)
		playsound(src.loc, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 50, 1)
		user.TakeDamage("chest", 150, 0)
		SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
		return 1

/obj/item/scrapweapons/weapons/club
	name = "scrap club"
	desc = "A metal shaft attached to a handle. You might be able to improve it a bit."
	HELP_MESSAGE_OVERRIDE("To improve the club you should first attach some <b>wires</b> to the club, then attach a piece of <b>scrap metal, glass, or plasmaglass</b> as the studs.")
	icon_state = "club"
	item_state = "club"
	w_class = W_CLASS_NORMAL
	hit_type = DAMAGE_BLUNT
	force = 9
	throwforce = 6
	custom_suicide = 1
	attack_verbs = "smashes"
	hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
	custom_suicide = 1
	var/wireadded = FALSE

	scrapmetal
		desc = "A horrifyingly heavy amalgamation of scrap metal vaguely resembling a club or a bat."
		icon_state = "club-scrapmetal"
		item_state = "club-scrapmetal"
		HELP_MESSAGE_OVERRIDE(null)
		w_class = W_CLASS_NORMAL
		force = 11
		stamina_cost = 30
		stamina_damage = 35

	glass
		desc = "A horrifying amalgamation of scrap metal and glass vaguely resembling a club or a bat."
		icon_state = "club-glass"
		item_state = "club-glass"
		HELP_MESSAGE_OVERRIDE(null)
		w_class = W_CLASS_NORMAL
		hit_type = DAMAGE_CUT
		force = 11
		stamina_cost = 20
		stamina_damage = 25
		hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	plasmaglass
		desc = "A horrifying amalgamation of scrap metal and plasmaglass vaguely resembling a club or bat."
		icon_state = "club-pglass"
		item_state = "club-pglass"
		HELP_MESSAGE_OVERRIDE(null)
		w_class = W_CLASS_NORMAL
		hit_type = DAMAGE_CUT
		force = 12
		stamina_cost = 20
		stamina_damage = 25
		hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	attackby(obj/item/W, mob/user)
		. = ..()
		if (!src.wireadded)
			if (istype(W, /obj/item/cable_coil))
				if (W.amount >= 2)
					W.amount -= 2
					src.wireadded = TRUE
					boutput(user, SPAN_NOTICE("You attach the wire to the club, now you just need some extra material."))
					src.desc = "A metal shaft attached to a handle with wire wrapped around it. You should be able to improve it further."
					src.help_message = "Now attach a piece of <b>scrap metal, glass, or plasmaglass</b>. to complete the club."
					src.icon_state = "club-wire"
					src.item_state = "club-wire"
		else if (istype(W, /obj/item/raw_material/scrap_metal))
			W.change_stack_amount(-1)
			qdel(src)
			user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/club/scrapmetal)
			boutput(user, SPAN_NOTICE("You combine the club with the piece of scrap metal to add some extra weight."))

		else if (istype(W, /obj/item/raw_material/shard))
			if (istype(W.material, /datum/material/crystal/glass))
				W.change_stack_amount(-1)
				qdel(src)
				user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/club/glass)
				boutput(user, SPAN_NOTICE("You combine the club with the glass shard."))

			else if (istype(W.material, /datum/material/crystal/plasmaglass))
				W.change_stack_amount(-1)
				qdel(src)
				user.put_in_hand_or_drop(new/obj/item/scrapweapons/weapons/club/plasmaglass)
				boutput(user, SPAN_NOTICE("You combine the club with the glass shard"))

/obj/item/scrapweapons/weapons/club/suicide(var/mob/living/carbon/human/user as mob)
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	else
		user.visible_message(SPAN_ALERT("<b>[user] swings [his_or_her(user)] [src] in a mighty arc around [his_or_her(user)] head faster and faster until it hits [his_or_her(user)] head and knocks it clean off! [pick("Holy fucking shit", "Jesus christ what a show", "How is that even possible?", "Nice")]! </b>"))
		user.organHolder.drop_and_throw_organ("head", dist = 5, speed = 1, showtext = 1)
		playsound(src.loc, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 50, 1)
		SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
		return 1

/obj/item/scrapweapons/weapons/dagger
	name = "scrap dagger"
	desc = "A tiny bit of pointy scrap attached to a handle. Looks like it will give you tetanus just holding it."
	icon_state = "dagger"
	item_state = "dagger"
	hit_type = DAMAGE_STAB
	w_class = W_CLASS_SMALL
	tool_flags = TOOL_CUTTING
	event_handler_flags = USE_GRAB_CHOKE
	force = 7
	throwforce = 7
	attack_verbs = "stabs"
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	custom_suicide = 1

	New()
		..()
		src.setItemSpecial(/datum/item_special/double)

	glass
		desc = "A tiny bit of glass attached to a handle. You might cut yourself just holding it."
		icon_state = "dagger-glass"
		item_state = "dagger-glass"

	plasmaglass
		desc = "A tiny bit of plasmaglass attached to a handle. You might cut yourself just holding it."
		icon_state = "dagger-pglass"
		item_state = "dagger-pglass"
		force = 8

/obj/item/scrapweapons/weapons/dagger/suicide(var/mob/living/carbon/human/user as mob)
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	else
		user.visible_message(SPAN_ALERT("<b>[user] slashes [his_or_her(user)] own throat with [src]!</b>"))
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		playsound(src.loc, 'sound/impact_sounds/Flesh_Cut_1.ogg', 50, 1)
		SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
		return 1
