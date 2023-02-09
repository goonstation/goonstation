
// haine wuz here and tore this file to bits!!!  f u we can have things in their own files and we SHOULD
// rather than EVERYTHING BEING IN HALLOWEEN.DM AND KEELINSSTUFF.DM OKAY THINGS CAN BE IN OTHER FILES

/obj/item/storage
	name = "storage"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "box_blank"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"
	/// Types that will be accepted
	var/list/can_hold = null//new/list()
	/// Exact types that will be accepted, in addition to can_hold
	var/list/can_hold_exact = null
	/// If can_hold has stuff in it, if this is set, something will fit if it's at or below max_wclass OR if it's in can_hold, otherwise only things in can_hold will fit
	var/in_list_or_max = 0
	var/datum/hud/storage/hud
	/// Don't print a visible message on use.
	var/sneaky = 0
	/// Prevent accessing storage when clicked in pocket
	var/does_not_open_in_pocket = 1
	/// Maximum  w_class that can be held
	var/max_wclass = W_CLASS_SMALL
	/// Number of storage slots, even numbers overlap the close button for the on-ground hud layout
	var/slots = 7
	/// Initial contents when created
	var/list/spawn_contents = list()
	/// specify if storage should grab other items on turf
	var/grab_stuff_on_spawn = FALSE
	move_triggered = 1
	flags = FPRINT | TABLEPASS | NOSPLASH
	w_class = W_CLASS_NORMAL
	mechanics_interaction = MECHANICS_INTERACTION_SKIP_IF_FAIL

		//cogwerks - burn vars
	burn_point = 2500
	burn_output = 2500
	burn_possible = 1
	health = 10

	buildTooltipContent()
		. = ..()
		var/list/L = get_contents()
		. += "<br>Holding [length(L)]/[slots] objects"
		lastTooltipContent = .

	// TODO: initalize
	New()
		src.storage = new /datum/storage(src, spawn_contents, can_hold, in_list_or_max, max_wclass, slots, sneaky, does_not_open_in_pocket)
		src.make_my_stuff()
		..()

	// override this with specific additions to add to the storage
	proc/make_my_stuff()
		return

	attack(mob/M, mob/user)
		if (surgeryCheck(M, user))
			insertChestItem(M, user)
			return
		..()

	proc/get_contents()
		return src.storage?.get_contents()

	proc/add_contents(atom/A)
		src.storage.add_contents(A)

	proc/get_all_contents()
		return src.storage.get_all_contents()

	proc/check_can_hold(atom/A)
		return src.storage.check_can_hold(A)

/obj/item/storage/box
	name = "box"
	icon_state = "box"
	desc = "A box that can hold a number of small items."
	max_wclass = W_CLASS_SMALL

	attackby(obj/item/W, mob/user, obj/item/storage/T)
		if (istype(W, /obj/item/storage/toolbox) || istype(W, /obj/item/storage/box) || istype(W, /obj/item/storage/belt))
			var/obj/item/storage/S = W
			for (var/obj/item/I in S.get_contents())
				if (..(I, user, S) == 0)
					break
			return
		else
			return ..()

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
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH
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

/obj/item/storage/desk_drawer
	name = "desk drawer"
	desc = "This fits into a desk and you can store stuff in it! Wow, amazing!!"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "desk_drawer"
	flags = FPRINT | TABLEPASS
	w_class = W_CLASS_BULKY
	max_wclass = W_CLASS_SMALL
	slots = 13 // these can't move (in theory) and they can only hold w_class 2 things so we may as well let them hold a bunch
	mechanics_type_override = /obj/item/storage/desk_drawer
	var/locked = 0
	var/id = null

	attackby(obj/item/W, mob/user, obj/item/storage/T)
		if (istype(W, /obj/item/device/key/filing_cabinet))
			var/obj/item/device/key/K = W
			if (src.id && K.id == src.id)
				src.locked = !src.locked
				user.visible_message("[user] [!src.locked ? "un" : null]locks [src].")
				playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
			else
				boutput(user, "<span class='alert'>[K] doesn't seem to fit in [src]'s lock.</span>")
			return
		..()

	mouse_drop(atom/over_object, src_location, over_location)
		if (src.locked)
			if (usr)
				boutput(usr, "<span class='alert'>[src] is locked!</span>")
			return
		..()

/obj/item/storage/rockit
	name = "\improper Rock-It Launcher"
	desc = "Huh..."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "rockit"
	item_state = "gun"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_BULKY
	max_wclass = W_CLASS_NORMAL
	var/fire_delay = 0.4 SECONDS

	New()
		..()
		src.setItemSpecial(null)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (target == loc)
			return
		if (!src.contents.len)
			return
		if (ON_COOLDOWN(src, "rockit_firerate", src.fire_delay))
			return
		var/obj/item/I = pick(src.contents)
		if (!I)
			return

		I.set_loc(get_turf(src.loc))
		I.dropped(user)
		src.hud.remove_item(I) //fix the funky UI stuff
		I.layer = initial(I.layer)
		I.throw_at(target, 8, 2, bonus_throwforce=8)

		playsound(src, 'sound/effects/singsuck.ogg', 40, 1)
