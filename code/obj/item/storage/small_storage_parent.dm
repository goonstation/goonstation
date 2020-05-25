
// haine wuz here and tore this file to bits!!!  f u we can have things in their own files and we SHOULD
// rather than EVERYTHING BEING IN HALLOWEEN.DM AND KEELINSSTUFF.DM OKAY THINGS CAN BE IN OTHER FILES

/obj/item/storage
	name = "storage"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "box_blank"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"
	var/list/spawn_contents = list()
	move_triggered = 1
	flags = FPRINT | TABLEPASS | NOSPLASH
	w_class = 3.0

		//cogwerks - burn vars
	burn_point = 2500
	burn_output = 2500
	burn_possible = 1
	health = 10

	buildTooltipContent()
		var/Tcontent = ..()
		var/list/L = get_contents()
		Tcontent += "<br>Holding [L.len]/[slots] objects"

		return Tcontent

	New()
		..()
		AddComponent(/datum/component/storage, src.spawn_contents)

	/*proc/update_icon()
		return*/

/obj/item/storage/box
	name = "box"
	icon_state = "box"
	desc = "A box that can hold a number of small items."
	max_wclass = 2

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/storage/toolbox) || istype(W, /obj/item/storage/box) || istype(W, /obj/item/storage/belt))
			var/obj/item/storage/S = W
			var/datum/component/storage/SC = S.GetComponent(/datum/component/storage)
			for (var/obj/item/I in SC?.get_contents())
				if (..(I, user, null, S) == 0)
					break
			return
		else
			return ..()

/obj/item/storage/box/starter // the one you get in your backpack
	spawn_contents = list(/obj/item/clothing/mask/breath)
	make_my_stuff()
		..()
		if (prob(15))
			new /obj/item/tank/emergency_oxygen(src)
		if (prob(10)) // put these together
			new /obj/item/clothing/suit/space/emerg(src)
			new /obj/item/clothing/head/emerg(src)

/obj/item/storage/box/starter/withO2
	spawn_contents = list(/obj/item/clothing/mask/breath,/obj/item/tank/emergency_oxygen)

/obj/item/storage/pill_bottle
	name = "pill bottle"
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	can_hold = list(/obj/item/reagent_containers/pill)
	w_class = 2.0
	max_wclass = 1
	desc = "A small bottle designed to carry pills. Does not come with a child-proof lock, as that was determined to be too difficult for the crew to open."

/obj/item/storage/briefcase
	name = "briefcase"
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	max_wclass = 3
	desc = "A fancy synthetic leather-bound briefcase, capable of holding a number of small objects, with style."
	stamina_damage = 35
	stamina_cost = 30
	stamina_crit_chance = 10
	spawn_contents = list(/obj/item/paper = 2,/obj/item/pen)
	// Don't use up more slots, certain job datums put items in the briefcase the player spawns with.
	// And nobody needs six sheets of paper right away, realistically speaking.

	New()
		..()
		BLOCK_BOOK

/obj/item/storage/desk_drawer
	name = "desk drawer"
	desc = "This fits into a desk and you can store stuff in it! Wow, amazing!!"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "desk_drawer"
	flags = FPRINT | TABLEPASS
	w_class = 4.0
	max_wclass = 2
	slots = 13 // these can't move (in theory) and they can only hold w_class 2 things so we may as well let them hold a bunch
	mechanics_type_override = /obj/item/storage/desk_drawer
	var/locked = 0
	var/id = null

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/device/key/filing_cabinet))
			var/obj/item/device/key/K = W
			if (src.id && K.id == src.id)
				src.locked = !src.locked
				user.visible_message("[user] [!src.locked ? "un" : null]locks [src].")
				playsound(get_turf(src), "sound/items/Screwdriver2.ogg", 50, 1)
			else
				boutput(user, "<span class='alert'>[K] doesn't seem to fit in [src]'s lock.</span>")
			return
		..()

	MouseDrop(atom/over_object, src_location, over_location)
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
	w_class = 4.0
	max_wclass = 3

	New()
		..()
		src.setItemSpecial(null)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (target == loc)
			return
		if (!src.contents.len)
			return
		var/obj/item/I = pick(src.contents)
		if (!I)
			return

		I.throwforce += 8 //Ugly. Who cares.
		SPAWN_DBG(1.5 SECONDS)
			if (I)
				I.throwforce -= 8

		I.set_loc(get_turf(src.loc))
		I.dropped()
		src.hud.remove_item(I) //fix the funky UI stuff
		I.layer = initial(I.layer)
		I.throw_at(target, 8, 2)

		playsound(src, 'sound/effects/singsuck.ogg', 40, 1)
