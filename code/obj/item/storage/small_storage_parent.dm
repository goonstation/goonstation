
// haine wuz here and tore this file to bits!!!  f u we can have things in their own files and we SHOULD
// rather than EVERYTHING BEING IN HALLOWEEN.DM AND KEELINSSTUFF.DM OKAY THINGS CAN BE IN OTHER FILES

/obj/item/storage
	name = "storage"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "box_blank"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"
	// variables here are copied from /datum/storage
	var/list/can_hold = null
	var/list/can_hold_exact = null
	var/list/prevent_holding = null
	var/check_wclass = 0
	var/datum/hud/storage/hud
	var/sneaky = 0
	var/stealthy_storage = FALSE
	var/opens_if_worn = FALSE
	var/max_wclass = W_CLASS_SMALL
	var/slots = 7
	var/list/spawn_contents = list()
	move_triggered = 1
	flags = TABLEPASS | NOSPLASH
	w_class = W_CLASS_NORMAL
	mechanics_interaction = MECHANICS_INTERACTION_SKIP_IF_FAIL

		//cogwerks - burn vars
	burn_point = 2500
	burn_output = 2500
	burn_possible = TRUE
	health = 10

	New()
		src.create_storage(/datum/storage, spawn_contents, can_hold, can_hold_exact, prevent_holding, check_wclass, max_wclass, slots, sneaky, stealthy_storage, opens_if_worn)
		src.make_my_stuff()
		..()

	// override this with specific additions to add to the storage
	proc/make_my_stuff()
		return

	combust()
		..()
		for (var/obj/item/I as anything in src.storage.get_contents())
			I.temperature_expose(null, src.burn_output)

	process_burning()
		for (var/obj/item/I as anything in src.storage.get_contents())
			I.temperature_expose(null, src.burn_output)
		. = ..()

	combust_ended()
		if (src.health <= 0) // okay lets make sure it actually fully burned and not just got extinguished
			for (var/obj/item/I as anything in src.storage.get_contents())
				src.storage.transfer_stored_item(I, get_turf(src))
		. = ..()

/obj/item/storage/box
	name = "box"
	icon_state = "box"
	desc = "A box that can hold a number of small items."
	max_wclass = W_CLASS_SMALL

/obj/item/storage/box/starter // the one you get in your backpack
	icon_state = "emergbox"
	spawn_contents = list(/obj/item/clothing/mask/breath, /obj/item/tank/emergency_oxygen)
	make_my_stuff(onlyMaskAndOxygen)
		..()
		if (prob(15) || ticker?.round_elapsed_ticks > 20 MINUTES && !onlyMaskAndOxygen) //aaaaaa
			src.storage.add_contents(new /obj/item/tank/emergency_oxygen(src))
		if (ticker?.round_elapsed_ticks > 20 MINUTES && !onlyMaskAndOxygen)
			src.storage.add_contents(new /obj/item/crowbar/red(src))
#ifdef MAP_OVERRIDE_NADIR //guarantee protective gear
		src.storage.add_contents(new /obj/item/clothing/suit/space/emerg(src))
		src.storage.add_contents(new /obj/item/clothing/head/emerg(src))
#else
		if (prob(10)) // put these together
			src.storage.add_contents(new /obj/item/clothing/suit/space/emerg(src))
			src.storage.add_contents(new /obj/item/clothing/head/emerg(src))
#endif


/obj/item/storage/box/starter/withO2 //use this if the box should not get additional items after the round has passed 20 min
	spawn_contents = list(/obj/item/clothing/mask/breath, /obj/item/tank/emergency_oxygen)
	make_my_stuff()
		..(TRUE)

/obj/item/storage/pill_bottle
	name = "pill bottle"
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	can_hold = list(/obj/item/reagent_containers/pill)
	w_class = W_CLASS_SMALL
	max_wclass = W_CLASS_TINY
	desc = "A small bottle designed to carry pills. Does not come with a child-proof lock, as that was determined to be too difficult for the crew to open."

/obj/item/storage/briefcase
	name = "briefcase"
	icon_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "briefcase"
	flags = TABLEPASS| CONDUCT | NOSPLASH
	force = 8
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_BULKY
	max_wclass = W_CLASS_NORMAL
	desc = "A fancy synthetic leather-bound briefcase, capable of holding a number of small objects, with style."
	stamina_damage = 40
	stamina_cost = 17
	stamina_crit_chance = 10
	spawn_contents = list(/obj/item/paper = 2,/obj/item/pen)
	// Don't use up more slots, certain job datums put items in the briefcase the player spawns with.
	// And nobody needs six sheets of paper right away, realistically speaking.

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)

/obj/item/storage/briefcase/toxins
	name = "toxins research briefcase"
	icon_state = "briefcase_rd"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "rd-case"
	max_wclass = W_CLASS_BULKY// parity with secure briefcase
	desc = "A large briefcase for experimental toxins research."
	spawn_contents = list(/obj/item/raw_material/molitz_beta = 2, /obj/item/paper/hellburn)

/obj/item/storage/rockit
	name = "\improper Rock-It Launcher"
	desc = "Huh..."
	icon = 'icons/obj/items/guns/gimmick.dmi'
	icon_state = "rockit"
	item_state = "gun"
	flags = EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_BULKY
	max_wclass = W_CLASS_NORMAL
	var/fire_delay = 0.4 SECONDS

	New()
		..()
		src.setItemSpecial(null)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (target == loc)
			return
		if (!length(src.storage.get_contents()))
			return
		if (ON_COOLDOWN(src, "rockit_firerate", src.fire_delay))
			return
		var/obj/item/I = pick(src.storage.get_contents())
		if (!I)
			return

		src.storage.transfer_stored_item(I, get_turf(src.loc))
		I.dropped(user)
		I.layer = initial(I.layer)
		I.throw_at(target, 8, 2, bonus_throwforce=8)

		playsound(src, 'sound/effects/singsuck.ogg', 40, TRUE)
