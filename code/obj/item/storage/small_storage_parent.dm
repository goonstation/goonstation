
// haine wuz here and tore this file to bits!!!  f u we can have things in their own files and we SHOULD
// rather than EVERYTHING BEING IN HALLOWEEN.DM AND KEELINSSTUFF.DM OKAY THINGS CAN BE IN OTHER FILES

/obj/item/storage
	name = "storage"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "box_blank"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"
	var/list/can_hold = null//new/list()
	var/in_list_or_max = 0 // sorry for the dumb var name - if can_hold has stuff in it, if this is set, something will fit if it's at or below max_wclass OR if it's in can_hold, otherwise only things in can_hold will fit
	var/datum/hud/storage/hud
	var/sneaky = 0 //Don't print a visible message on use.
	var/does_not_open_in_pocket = 1
	var/max_wclass = 2
	var/slots = 7 // seems that even numbers are what breaks the on-ground hud layout
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
		. = ..()
		var/list/L = get_contents()
		. += "<br>Holding [L.len]/[slots] objects"
		lastTooltipContent = .

	New()
		hud = new(src)
		..()
		SPAWN_DBG(1 DECI SECOND)
			src.make_my_stuff()

	disposing()
		if (hud)
			for (var/mob/M in hud.mobs)
				if (M.s_active == src)
					M.s_active = null
		qdel(hud)
		hud = null
		..()

	move_trigger(var/mob/M, kindof)
		if (..())
			for (var/obj/O in contents)
				if (O.move_triggered)
					O.move_trigger(M, kindof)

	emp_act()
		if (src.contents.len)
			for (var/atom/A in src.contents)
				if (isitem(A))
					var/obj/item/I = A
					I.emp_act()
		return

	proc/update_icon()
		return

	proc/make_my_stuff() // use this rather than overriding the container's New()
		if (!islist(src.spawn_contents) || !src.spawn_contents.len)
			return 0
		var/total_amt = 0
		for (var/thing in src.spawn_contents)
			var/amt = 1
			if (!ispath(thing))
				continue
			if (isnum(spawn_contents[thing])) //Instead of duplicate entries in the list, let's make them associative
				amt = abs(spawn_contents[thing])
			total_amt += amt
			for (amt, amt>0, amt--)
				new thing(src)
		if (total_amt > slots)
			logTheThing("debug", null, null, "STORAGE ITEM: [src] has more than [slots] items in it!")
		total_amt = null
		return 1

	attack(mob/M as mob, mob/user as mob)
		if (surgeryCheck(M, user))
			insertChestItem(M, user)
			return
		..()

	afterattack(obj/O as obj, mob/user as mob)
		if (O in src.contents)
			user.drop_item()
			SPAWN_DBG(1 DECI SECOND)
				O.attack_hand(user)
		else if (isitem(O) && !istype(O, /obj/item/storage) && !O.anchored)
			src.attackby(O, user)

	//failure returns 0 or lower for diff messages - sorry
	proc/check_can_hold(obj/item/W)
		if (!W)
			return 0
		.= 1
		if (W.cant_drop)
			return -1
		if (islist(src.can_hold) && src.can_hold.len)
			var/ok = 0
			if (src.in_list_or_max && W.w_class <= src.max_wclass)
				ok = 1
			else
				for (var/A in src.can_hold)
					if (ispath(A) && istype(W, A))
						ok = 1
			if (!ok)
				return 0

		else if (W.w_class > src.max_wclass)
			return -1

		var/list/my_contents = src.get_contents()
		if (my_contents.len >= slots)
			return -2

	attackby(obj/item/W, mob/user, params, obj/item/storage/T) // T for transfer - transferring items from one storage obj to another
		var/canhold = src.check_can_hold(W,user)
		if (canhold <= 0)
			switch (canhold)
				if(0)
					boutput(user, "<span class='alert'>[src] cannot hold [W].</span>")
				if(-1)
					boutput(user, "<span class='alert'>[W] won't fit into [src]!</span>")
				if(-2)
					boutput(user, "<span class='alert'>[src] is full!</span>")
			return

		var/atom/checkloc = src.loc // no infinite loops for you
		while (checkloc && !isturf(src.loc))
			if (checkloc == W) // nope
				//Hi hello this used to gib the user and create an actual 5x5 explosion on their tile
				//Turns out this condition can be met and reliably reproduced by players!
				//Lets not give players the ability to fucking explode at will eh
				return
			checkloc = checkloc.loc

		if (T && istype(T, /obj/item/storage))
			src.add_contents(W)
			T.hud.remove_item(W)
		else
			src.add_contents(W)
			user.u_equip(W)
		hud.add_item(W)
		update_icon()
		add_fingerprint(user)
		animate_storage_rustle(src)
		if (!src.sneaky && !istype(W, /obj/item/gun/energy/crossbow))
			user.visible_message("<span class='notice'>[user] has added [W] to [src]!</span>", "<span class='notice'>You have added [W] to [src].</span>")
		playsound(src.loc, "rustle", 50, 1, -5)
		return

	dropped(mob/user as mob)
		if (hud)
			hud.update()
		..()

	proc/mousetrap_check(mob/user)
		if (!ishuman(user) || user.stat)
			return
		for (var/obj/item/mousetrap/MT in src)
			if (MT.armed)
				user.visible_message("<span class='alert'><B>[user] reaches into \the [src] and sets off a mousetrap!</B></span>",\
				"<span class='alert'><B>You reach into \the [src], but there was a live mousetrap in there!</B></span>")
				MT.triggered(user, user.hand ? "l_hand" : "r_hand")
				. = 1
		for (var/obj/item/mine/M in src)
			if (M.armed && M.used_up != 1)
				user.visible_message("<span class='alert'><B>[user] reaches into \the [src] and sets off a [M.name]!</B></span>",\
				"<span class='alert'><B>You reach into \the [src], but there was a live [M.name] in there!</B></span>")
				M.triggered(user)
				. = 1

	MouseDrop(atom/over_object, src_location, over_location)
		..()
		var/obj/screen/hud/S = over_object
		if (istype(S))
			playsound(src.loc, "rustle", 50, 1, -5)
			if (!usr.restrained() && !usr.stat && src.loc == usr)
				if (S.id == "rhand")
					if (!usr.r_hand)
						usr.u_equip(src)
						usr.put_in_hand(src, 0)
				else
					if (S.id == "lhand")
						if (!usr.l_hand)
							usr.u_equip(src)
							usr.put_in_hand(src, 1)
				return
		if (over_object == usr && in_range(src, usr) && isliving(usr) && !usr.stat)
			if (usr.s_active)
				usr.detach_hud(usr.s_active)
				usr.s_active = null
			if (src.mousetrap_check(usr))
				return
			usr.s_active = src.hud
			hud.update()
			usr.attach_hud(src.hud)
			return
		if (usr.is_in_hands(src))
			var/turf/T = over_object
			if (istype(T, /obj/table))
				T = get_turf(T)
			if (!(usr in range(1, T)))
				return
			if (istype(T))
				for (var/obj/O in T)
					if (O.density && !istype(O, /obj/table) && !istype(O, /obj/rack))
						return
				if (!T.density)
					usr.visible_message("<span class='alert'>[usr] dumps the contents of [src] onto [T]!</span>")
					for (var/obj/item/I in src)
						I.set_loc(T)
						I.layer = initial(I.layer)
						if (istype(I, /obj/item/mousetrap))
							var/obj/item/mousetrap/MT = I
							if (MT.armed)
								MT.visible_message("<span class='alert'>[MT] triggers as it falls on the ground!</span>")
								MT.triggered(usr, null)
						else if (istype(I, /obj/item/mine))
							var/obj/item/mine/M = I
							if (M.armed && M.used_up != 1)
								M.visible_message("<span class='alert'>[M] triggers as it falls on the ground!</span>")
								M.triggered(usr)
						hud.remove_item(I)

	attack_hand(mob/user as mob)
		if (!src.sneaky)
			playsound(src.loc, "rustle", 50, 1, -2)
		if (src.loc == user && (!does_not_open_in_pocket || src == user.l_hand || src == user.r_hand))
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.limbs) // this check is probably dumb. BUT YOU NEVER KNOW
					if ((src == H.l_hand && istype(H.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item)) || (src == H.r_hand && istype(H.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item)))
						return
			if (user.s_active)
				user.detach_hud(user.s_active)
				user.s_active = null
			if (src.mousetrap_check(user))
				return
			user.s_active = src.hud
			hud.update()
			user.attach_hud(src.hud)
			src.add_fingerprint(user)
			animate_storage_rustle(src)
		else
			..()
			for (var/mob/M in hud.mobs)
				if (M != user)
					M.detach_hud(hud)
			hud.update()

	attack_self(mob/user as mob)
		..()
		attack_hand(user)

	proc/get_contents()
		RETURN_TYPE(/list)
		var/list/cont = src.contents.Copy()
		for(var/atom/A in cont)
			if(!istype(A, /obj/item) || istype(A, /obj/item/grab))
				cont.Remove(A)
		return cont

	proc/add_contents(obj/item/I)
		I.set_loc(src)

	proc/get_all_contents()
		var/list/L = list()
		L += get_contents()
		for (var/obj/item/storage/S in get_contents())
			L += S.get_all_contents()
		return L

/obj/item/storage/box
	name = "box"
	icon_state = "box"
	desc = "A box that can hold a number of small items."
	max_wclass = 2

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/storage/toolbox) || istype(W, /obj/item/storage/box) || istype(W, /obj/item/storage/belt))
			var/obj/item/storage/S = W
			for (var/obj/item/I in S.get_contents())
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
	stamina_damage = 40
	stamina_cost = 17
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
